//
//  ServerEndpointView.swift
//  FindMySync
//
//  Created by ZZZ on 11/01/23.
//

import SwiftUI

struct ServerEndpointView: View {

	@State private var transport: String = UserDefaults.standard.string(
		forKey: "endpoint_transport")!

	@State private var url: String = UserDefaults.standard.string(forKey: "endpoint_url")!
	@State private var auth: String = UserDefaults.standard.string(forKey: "endpoint_auth")!

	@State private var mqttHost: String = UserDefaults.standard.string(forKey: "mqtt_host")!
	@State private var mqttPort: String = UserDefaults.standard.string(forKey: "mqtt_port")!
	@State private var mqttTls: Bool = UserDefaults.standard.bool(forKey: "mqtt_tls")
	@State private var mqttUsername: String = UserDefaults.standard.string(
		forKey: "mqtt_username")!
	@State private var mqttPassword: String = UserDefaults.standard.string(
		forKey: "mqtt_password")!
	@State private var mqttDiscoveryPrefix: String = UserDefaults.standard.string(
		forKey: "mqtt_discovery_prefix")!
	@State private var mqttBaseTopic: String = UserDefaults.standard.string(
		forKey: "mqtt_base_topic")!

	var body: some View {
		ScrollView {
			VStack {
				// A plain Binding rather than onChange, which needs macOS 11.
				Picker(
					"Send data via",
					selection: Binding(
						get: { transport },
						set: { value in
							transport = value
							UserDefaults.standard.set(
								value, forKey: "endpoint_transport")

							Synchronizer.shared.fetchData()
						})
				) {
					Text("HTTP (device_tracker.see)").tag("http")
					Text("MQTT (discovery)").tag("mqtt")
				}
				.pickerStyle(SegmentedPickerStyle())
				.padding()
				.background(Color(NSColor.controlBackgroundColor))
				.cornerRadius(12)

				if transport == "mqtt" {
					TextFieldView(
						title: "Broker host",
						value: $mqttHost,
						subtitle: "Hostname of your MQTT broker",
						onChange: {
							UserDefaults.standard.set(
								mqttHost, forKey: "mqtt_host")

							Synchronizer.shared.fetchData()
						}
					)
					TextFieldView(
						title: "Broker port",
						value: $mqttPort,
						subtitle: "1883 plain, 8883 over TLS",
						onChange: {
							UserDefaults.standard.set(
								mqttPort, forKey: "mqtt_port")

							Synchronizer.shared.fetchData()
						}
					)
					CheckboxView(
						title: "Use TLS",
						value: $mqttTls,
						subtitle: "Broker certificate must be trusted by this Mac",
						onChange: {
							mqttTls.toggle()
							UserDefaults.standard.set(
								mqttTls, forKey: "mqtt_tls")

							Synchronizer.shared.fetchData()
						}
					)
					TextFieldView(
						title: "Username",
						value: $mqttUsername,
						subtitle: "Leave empty for an anonymous broker",
						onChange: {
							UserDefaults.standard.set(
								mqttUsername, forKey: "mqtt_username")

							Synchronizer.shared.fetchData()
						}
					)
					TextFieldView(
						title: "Password",
						value: $mqttPassword,
						subtitle: "Leave empty for an anonymous broker",
						onChange: {
							UserDefaults.standard.set(
								mqttPassword, forKey: "mqtt_password")

							Synchronizer.shared.fetchData()
						}
					)
					TextFieldView(
						title: "Discovery prefix",
						value: $mqttDiscoveryPrefix,
						subtitle: "Where Home Assistant looks for new devices",
						onChange: {
							UserDefaults.standard.set(
								mqttDiscoveryPrefix,
								forKey: "mqtt_discovery_prefix")

							Synchronizer.shared.fetchData()
						}
					)
					TextFieldView(
						title: "Base topic",
						value: $mqttBaseTopic,
						subtitle: "Where locations are published",
						onChange: {
							UserDefaults.standard.set(
								mqttBaseTopic, forKey: "mqtt_base_topic")

							Synchronizer.shared.fetchData()
						}
					)
				} else {
					TextFieldView(
						title: "URL",
						value: $url,
						subtitle: "Where data will be sent",
						onChange: {
							UserDefaults.standard.set(
								url, forKey: "endpoint_url")

							Synchronizer.shared.fetchData()
						}
					)
					TextFieldView(
						title: "Authorization header",
						value: $auth,
						subtitle: "Authorize request",
						onChange: {
							UserDefaults.standard.set(
								auth, forKey: "endpoint_auth")

							Synchronizer.shared.fetchData()
						}
					)

					Text(
						"Home Assistant removes the device_tracker.see action in 2027.5. Switch to MQTT before then."
					)
					.font(.callout)
					.foregroundColor(.secondary)
					.fixedSize(horizontal: false, vertical: true)
					.frame(maxWidth: .infinity, alignment: .leading)
					.padding()
				}
			}
			.padding()
		}
	}
}
