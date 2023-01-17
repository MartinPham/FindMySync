//
//  Synchronizer.swift
//  FindMySync
//
//  Created by ZZZ on 17/01/23.
//

import Foundation
import AXSwift
import UniformTypeIdentifiers

class Synchronizer {
    var log: (_ message: String) -> Void
    var clearLog: () -> Void
    var onAccessDenied: () -> Void
    var timer: Timer?
    
    static let shared = Synchronizer(
        log: { message in
            debugPrint(message)
        },
        clearLog: {
            debugPrint("========")
        },
        onAccessDenied: {
            debugPrint("ACCESS DENIED")
        }
    )
    
    public init(log: @escaping (_ message: String) -> Void, clearLog: @escaping () -> Void, onAccessDenied: @escaping () -> Void) {
        self.log = log
        self.clearLog = clearLog
        self.onAccessDenied = onAccessDenied
    }
    
    func fetchData() {
        clearLog()
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        log(dateFormatter.string(from: date) + "\n")
        
        log(Bundle.main.bundlePath)
        
        let items: Bool = UserDefaults.standard.bool(forKey: "sources_items")
        let devices: Bool = UserDefaults.standard.bool(forKey: "sources_devices")
        let hide_findmy_app: Bool = UserDefaults.standard.bool(forKey: "extra_hide_findmy_app")
        let generate_config: Bool = UserDefaults.standard.bool(forKey: "extra_generate_config")
        
        if hide_findmy_app {
            if UIElement.isProcessTrusted() {
                if let app = Application.allForBundleID("com.apple.findmy").first {
                    log("Found FindMy app, gonna hide it")
                    do {
                        try app.setAttribute(.hidden, value: true)
                    } catch {
                        log("Cannot hide FindMy app: \(error)")
                    }
                }
            } else {
                log("Cannot hide FindMy app because Accessibility API permission was not granted")
            }
        }
        
        let homeDirectory = URL(fileURLWithPath: NSHomeDirectory())
        log("Home directory: " + homeDirectory.absoluteString)
        
        var hasAccess = true
        var haConfig = ""
        
        if items {
            let itemsJsonFile = homeDirectory.appendingPathComponent("Library/Caches/com.apple.findmy.fmipcore/Items.data")
            
            log("Items file: " + itemsJsonFile.absoluteString)
            
            do {
                let data = try Data(contentsOf: itemsJsonFile, options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? [AnyObject] {
                    log("Got " + String(jsonResult.count) + " item(s):");
                    for item in jsonResult {
                        if let id = item["identifier"] as? String {
                            let name = item["name"] as! String
                            log("- Item \"" + name + "\" - " + id);
                            if let location = item["location"] as? [String: Any] {
                                if let latitude = location["latitude"] as? NSNumber,
                                   let longitude = location["longitude"] as? NSNumber,
                                   let accuracy = location["horizontalAccuracy"] as? NSNumber {
                                    log("- - Location: " + latitude.stringValue + ", " + longitude.stringValue + " (Accuracy " + accuracy.stringValue + ")")
                                    
                                    updateEntity(id: id, latitude: latitude, longitude: longitude, accuracy: accuracy, battery: -1)
                                    
                                    if generate_config {
                                        haConfig += """
findmy_\(id.replacingOccurrences(of: "-", with: "")):
  name: "\(name)"
  mac: FINDMY_\(id)
  icon:
  picture:
  track: true

"""
                                    }
                                } else {
                                    log("- - No latitude/longitude/accuracy provided");
                                }
                            } else {
                                log("- - No location provided");
                            }
                        }
                    }
                }
            } catch {
                log("Cannot read Items file:" + error.localizedDescription);
                hasAccess = false
            }
        }
        
        
        if devices {
            let devicesJsonFile = homeDirectory.appendingPathComponent("Library/Caches/com.apple.findmy.fmipcore/Devices.data")
            log("Devices file: " + devicesJsonFile.absoluteString)
            
            do {
                let data = try Data(contentsOf: devicesJsonFile, options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? [AnyObject] {
                    log("Got " + String(jsonResult.count) + " item(s):");
                    for item in jsonResult {
                        if let id = item["baUUID"] as? String {
                            let name = item["name"] as! String
                            log("- Item \"" + name + "\" - " + id);
                            if let location = item["location"] as? [String: Any] {
                                if let latitude = location["latitude"] as? NSNumber,
                                   let longitude = location["longitude"] as? NSNumber,
                                   let accuracy = location["horizontalAccuracy"] as? NSNumber {
                                    log("- - Location: " + latitude.stringValue + ", " + longitude.stringValue + " (Accuracy " + accuracy.stringValue + ")")
                                    
                                    if let battery = item["batteryLevel"] as? NSNumber {
                                        log("- - Battery level: " + battery.stringValue)
                                        updateEntity(id: id, latitude: latitude, longitude: longitude, accuracy: accuracy, battery: battery)
                                    } else {
                                        log("- - No battery level provided")
                                        updateEntity(id: id, latitude: latitude, longitude: longitude, accuracy: accuracy, battery: -1)
                                    }
                                    
                                    if generate_config {
                                        haConfig += """
findmy_\(id.replacingOccurrences(of: "-", with: "")):
  name: "\(name)"
  mac: FINDMY_\(id)
  icon:
  picture:
  track: true

"""
                                    }
                                } else {
                                    log("- - No latitude/longitude/accuracy provided");
                                }
                            } else {
                                log("- - No location provided");
                            }
                        }
                    }
                }
            } catch {
                log("Cannot read Items file:" + error.localizedDescription);
                hasAccess = false
            }
        }
        
        if !hasAccess {
            onAccessDenied()
        } else {
            if generate_config {
                log("")
                log("------ known_devices.yaml ------")
                log(haConfig)
                log("--------------------------------")
                log("")
            }
        }
        
        
        
        
        let interval: String = UserDefaults.standard.string(forKey: "extra_interval")!
        log("Scheduling next update after " + interval + " minutes");
        
        if let currentTimer = timer {
            currentTimer.invalidate()
        }
        self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(interval)! * 60, repeats: false) { t in
            self.fetchData()
        }
    }
    
    func updateEntity(id: String, latitude: NSNumber, longitude: NSNumber, accuracy: NSNumber, battery: NSNumber) {
        let url: String = UserDefaults.standard.string(forKey: "endpoint_url")!
        let auth: String = UserDefaults.standard.string(forKey: "endpoint_auth")!
        
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        guard let URL = URL(string: url) else {return}
        var request = URLRequest(url: URL)
        request.httpMethod = "POST"

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(auth, forHTTPHeaderField: "Authorization")

        var bodyObject: [String : Any] = [
            "dev_id": "findmy_" + id.replacingOccurrences(of: "-", with: ""),
            "gps": [
                latitude.floatValue,
                longitude.floatValue
            ],
            "gps_accuracy": accuracy.floatValue
        ]
        
        if(battery.floatValue > 0) {
            bodyObject["battery"] = (battery.floatValue > 0) ? (battery.floatValue * 100) : battery.floatValue
        }
        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
    
        
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                let statusCode = (response as! HTTPURLResponse).statusCode
                self.log("[" + id + "] Data sent: HTTP \(statusCode)")
            }
            else {
                self.log("[" + id + "] Data error: \(error!.localizedDescription)");
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
}
