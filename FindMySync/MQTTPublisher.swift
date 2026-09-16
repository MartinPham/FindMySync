//
//  MQTTPublisher.swift
//  FindMySync
//

import CocoaMQTT
import Foundation

/// Publishes FindMy locations to Home Assistant over MQTT.
///
/// Entities are created through MQTT discovery, so every FindMy device or item shows
/// up in Home Assistant as a device carrying a `device_tracker` and, when a battery
/// level is known, a battery `sensor`. Home Assistant resolves zones from the
/// published coordinates, the same way the deprecated `device_tracker.see` action did.
class MQTTPublisher {

    static let shared = MQTTPublisher()

    var log: (_ message: String) -> Void = { message in
        debugPrint(message)
    }

    /// The log sink writes to SwiftUI state, and everything below runs off the main
    /// thread.
    private func emit(_ message: String) {
        DispatchQueue.main.async {
            self.log(message)
        }
    }

    private struct Settings: Equatable {
        var host: String
        var port: UInt16
        var tls: Bool
        var username: String
        var password: String
        var discoveryPrefix: String
        var baseTopic: String

        static func current() -> Settings {
            let defaults = UserDefaults.standard
            return Settings(
                host: (defaults.string(forKey: "mqtt_host") ?? "").trimmingCharacters(
                    in: .whitespaces),
                port: UInt16(defaults.string(forKey: "mqtt_port") ?? "") ?? 1883,
                tls: defaults.bool(forKey: "mqtt_tls"),
                username: defaults.string(forKey: "mqtt_username") ?? "",
                password: defaults.string(forKey: "mqtt_password") ?? "",
                discoveryPrefix: defaults.string(forKey: "mqtt_discovery_prefix")
                    ?? "homeassistant",
                baseTopic: defaults.string(forKey: "mqtt_base_topic") ?? "findmysync"
            )
        }
    }

    /// Serialises every mutation of the state below, so the synchronizer can call
    /// `publish` from whatever thread it happens to be on.
    private let queue = DispatchQueue(label: "com.findmysync.mqtt")

    private var client: CocoaMQTT?
    private var settings: Settings?
    private var connected = false

    /// Topics whose discovery config has already been announced on this connection.
    private var announced: Set<String> = []

    /// Retained payloads waiting for a connection, keyed by topic so a slow broker
    /// never makes us send stale coordinates.
    private var pending: [String: String] = [:]

    // MARK: - Publishing

    /// Levels at or above this are what Apple itself warns about. Find My shows a
    /// low-battery icon for a beacon reporting 5 and nothing for 1, 2 or 4, which
    /// is the only calibration the system exposes - there is no four-bar gauge for
    /// accessories anywhere in the UI. The raw level is published alongside so the
    /// threshold can be revisited without guesswork.
    private static let batteryLowLevel = 5

    func publish(
        id: String, name: String, latitude: NSNumber, longitude: NSNumber,
        accuracy: NSNumber, battery: NSNumber, batteryLevel: NSNumber = -1,
        address: String
    ) {
        let settings = Settings.current()

        guard !settings.host.isEmpty else {
            emit("[" + id + "] MQTT broker host is not configured")
            return
        }

        queue.async {
            self.connect(using: settings)

            let object = MQTTPublisher.objectId(for: id)
            let hasBattery = battery.floatValue > 0
            let hasLevel = batteryLevel.intValue > 0

            // Republish discovery when a battery component appears, so an item that
            // only reports occasionally still ends up with the sensor.
            var announceKey = object
            if hasBattery { announceKey += "+battery" }
            if hasLevel { announceKey += "+level" }
            if !self.announced.contains(announceKey) {
                self.announced.insert(announceKey)
                self.enqueue(
                    topic: "\(settings.discoveryPrefix)/device/\(object)/config",
                    payload: self.discoveryPayload(
                        object: object, name: name, hasBattery: hasBattery,
                        hasLevel: hasLevel, settings: settings)
                )
            }

            var state: [String: Any] = [
                "latitude": latitude.doubleValue,
                "longitude": longitude.doubleValue,
                "gps_accuracy": accuracy.doubleValue,
            ]

            if hasBattery {
                state["battery_level"] = Int((battery.floatValue * 100).rounded())
            }

            if hasLevel {
                state["battery_low"] =
                    batteryLevel.intValue >= MQTTPublisher.batteryLowLevel
                // Published raw so the threshold above can be checked against
                // reality, and so anyone wanting the finer states can template on it.
                state["battery_state"] = batteryLevel.intValue
            }

            if !address.isEmpty {
                state["address"] = address
            }

            self.enqueue(
                topic: MQTTPublisher.stateTopic(object, settings),
                payload: MQTTPublisher.json(state)
            )

            self.emit(
                "[" + id + "] "
                    + (self.connected
                        ? "Published to " + settings.host
                        : "Queued for " + settings.host))
        }
    }

    // MARK: - Connection

    /// Builds the client on first use, and rebuilds it whenever the broker settings
    /// change. Reconnecting a dropped connection is left to CocoaMQTT.
    private func connect(using settings: Settings) {
        if client != nil && self.settings == settings {
            return
        }

        if let existing = client {
            emit("MQTT settings changed, reconnecting")
            existing.autoReconnect = false
            existing.disconnect()
        }

        connected = false
        announced.removeAll()

        let client = CocoaMQTT(
            clientID: MQTTPublisher.clientId(), host: settings.host, port: settings.port)

        if !settings.username.isEmpty {
            client.username = settings.username
        }
        if !settings.password.isEmpty {
            client.password = settings.password
        }

        client.enableSSL = settings.tls
        client.keepAlive = 60
        client.cleanSession = true
        client.autoReconnect = true
        client.willMessage = CocoaMQTTMessage(
            topic: MQTTPublisher.availabilityTopic(settings), string: "offline",
            qos: .qos1, retained: true)

        client.didConnectAck = { [weak self] mqtt, ack in
            guard let self = self else { return }
            self.queue.async {
                // Ignore a client we have already replaced on a settings change.
                guard self.client === mqtt else { return }
                guard ack == .accept else {
                    self.emit("MQTT connection refused: \(ack)")
                    return
                }
                self.emit("MQTT connected to \(settings.host):\(settings.port)")
                self.connected = true
                self.send(
                    topic: MQTTPublisher.availabilityTopic(settings), payload: "online")
                self.flush()
            }
        }

        client.didDisconnect = { [weak self] mqtt, error in
            guard let self = self else { return }
            self.queue.async {
                guard self.client === mqtt else { return }
                self.connected = false
                // Retained discovery can be lost with the broker, so announce again.
                self.announced.removeAll()
                if let error = error {
                    self.emit("MQTT disconnected: \(error.localizedDescription)")
                } else {
                    self.emit("MQTT disconnected")
                }
            }
        }

        self.client = client
        self.settings = settings

        if !client.connect() {
            emit("MQTT cannot connect to \(settings.host):\(settings.port)")
        }
    }

    // MARK: - Topics and payloads

    private func enqueue(topic: String, payload: String) {
        guard connected else {
            pending[topic] = payload
            return
        }
        send(topic: topic, payload: payload)
    }

    private func flush() {
        let queued = pending
        pending.removeAll()
        for (topic, payload) in queued {
            send(topic: topic, payload: payload)
        }
    }

    private func send(topic: String, payload: String) {
        client?.publish(topic, withString: payload, qos: .qos1, retained: true)
    }

    private func discoveryPayload(
        object: String, name: String, hasBattery: Bool, hasLevel: Bool,
        settings: Settings
    ) -> String {
        let stateTopic = MQTTPublisher.stateTopic(object, settings)

        var components: [String: Any] = [
            "tracker": [
                "p": "device_tracker",
                // A null name makes the entity take the device's own name.
                "name": NSNull(),
                "unique_id": object + "_tracker",
                "json_attributes_topic": stateTopic,
                "source_type": "gps",
            ]
        ]

        if hasBattery {
            components["battery"] = [
                "p": "sensor",
                "name": "Battery",
                "unique_id": object + "_battery",
                "device_class": "battery",
                "unit_of_measurement": "%",
                "state_class": "measurement",
                "state_topic": stateTopic,
                "value_template": "{{ value_json.battery_level }}",
            ]
        }

        // Accessories report a coarse level rather than a percentage, so this is a
        // binary_sensor - the same low / not-low that Find My itself shows - instead
        // of a gauge built on invented numbers.
        if hasLevel {
            components["battery_low"] = [
                "p": "binary_sensor",
                "name": "Battery low",
                "unique_id": object + "_battery_low",
                "device_class": "battery",
                "entity_category": "diagnostic",
                "state_topic": stateTopic,
                "value_template": "{{ 'ON' if value_json.battery_low else 'OFF' }}",
            ]
        }

        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "0"

        return MQTTPublisher.json([
            "dev": [
                "ids": object,
                "name": name.isEmpty ? object : name,
                "mf": "Apple",
                "mdl": "FindMy",
            ],
            "o": [
                "name": "FindMySync",
                "sw": version,
                "url": "https://github.com/martinpham/FindMySync",
            ],
            "availability_topic": MQTTPublisher.availabilityTopic(settings),
            "cmps": components,
        ])
    }

    private static func stateTopic(_ object: String, _ settings: Settings) -> String {
        return "\(settings.baseTopic)/\(object)/state"
    }

    private static func availabilityTopic(_ settings: Settings) -> String {
        return "\(settings.baseTopic)/status"
    }

    /// Matches the `findmy_<id>` naming the generated Home Assistant config has always
    /// used, reduced to the characters discovery topics allow.
    static func objectId(for id: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
        let cleaned = String(
            id.replacingOccurrences(of: "-", with: "").lowercased().unicodeScalars.map {
                allowed.contains($0) ? Character($0) : "_"
            })
        return "findmy_" + cleaned
    }

    /// A stable client id keeps the broker's session and last will tied to this install.
    private static func clientId() -> String {
        let defaults = UserDefaults.standard
        if let existing = defaults.string(forKey: "mqtt_client_id"), !existing.isEmpty {
            return existing
        }
        let generated = "findmysync-" + String(UUID().uuidString.prefix(8))
        defaults.set(generated, forKey: "mqtt_client_id")
        return generated
    }

    private static func json(_ object: [String: Any]) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []),
            let string = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }
        return string
    }
}
