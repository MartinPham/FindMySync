//
//  SidebarView.swift
//  FindMySync
//
//  Created by ZZZ on 11/01/23.
//

import SwiftUI
import AXSwift
import UniformTypeIdentifiers

struct SidebarView: View {
    @State var selection: Screen? = .home
    @State var logs = ""
    @State var timer: Timer?
    
    @AppStorage("bookmarkData") var findmyBookmark: Data?
    
    @State private var directoryDialogShowing = false
    @State private var fileAccessDialogShowing = false
    
    func log(_ message: String) {
        debugPrint(message)
        self.logs += message + "\n"
    }
    var body: some View {
        NavigationView {
            List {
                Text("SYNCHRONIZATION")
                    .font(.system(size: 10))
                    .fontWeight(.bold)
                Group{
                    NavigationLink(destination: HomeView(onDiscoverClick: {
                        selection = .status
                    }), tag: Screen.home, selection: $selection) {
                        Label("Home", systemImage: "house")
                    }
                    NavigationLink(destination: StatusView(logs: $logs, onForceUpdateClick: {
                        fetchData()
                    }), tag: Screen.status, selection: $selection) {
                        Label("Status", systemImage: "text.bubble")
                    }
                }
                Divider()
                
                
                Text("SETTINGS")
                    .font(.system(size: 10))
                    .fontWeight(.bold)
                Group {
                    NavigationLink(destination: DatasourcesView(), tag: Screen.data, selection: $selection) {
                        Label("Data", systemImage: "rectangle.stack")
                    }
                    NavigationLink(destination: ServerEndpointView(), tag: Screen.endpoint, selection: $selection) {
                        Label("Endpoint", systemImage: "globe")
                    }
                }
                
                
                Divider()
                NavigationLink(destination: AboutView(), tag: Screen.about, selection: $selection) {
                    Label("About", systemImage: "star")
                }
            }
            
            .listStyle(SidebarListStyle())
            .frame(minWidth: 100, idealWidth: 100, maxWidth: 300)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: toggleSidebar, label: {
                        Image(systemName: "sidebar.left")
                    })
                }
            }
            
            HomeView {
                selection = .endpoint
            }
        }
        .onAppear(perform: onAppear)
        .confirmationDialog("Ops! I can't read FindMy data", isPresented: $fileAccessDialogShowing) {
            Button("Grant permissions") {
                fileAccessDialogShowing = false
                directoryDialogShowing = true
            }
            Button("Help") {
                NSWorkspace.shared.open(URL(string: "https://www.martinpham.com/findmysync/")!)
            }
            Button("Cancel", role: .cancel) {
                fileAccessDialogShowing = false
            }
        } message: {
            Text("Please give me permessions to access ~/Library/Caches/com.apple.findmy.fmipcore")
        }
        .fileImporter(isPresented: $directoryDialogShowing, allowedContentTypes: [UTType.folder]) { result in
            switch result {
            case .success(let url):
                guard url.startAccessingSecurityScopedResource() else {
                    return
                }
                
                defer { url.stopAccessingSecurityScopedResource() }
                
                do {
                    findmyBookmark = try url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
                } catch {
                    log("Bookmark error \(error)")
                }
            case .failure(let error):
                log("Importer error: \(error)")
            }
            directoryDialogShowing = false
        }
    }
    
    func onAppear() {
        
        
        
        fetchData()
    }
    
    func fetchData() {
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        logs = dateFormatter.string(from: date) + "\n"
        
        log(Bundle.main.bundlePath)
        
        let items: Bool = UserDefaults.standard.bool(forKey: "sources_items")
        let devices: Bool = UserDefaults.standard.bool(forKey: "sources_devices")
        let sources_hideapp: Bool = UserDefaults.standard.bool(forKey: "sources_hideapp")
        
        if sources_hideapp {
            if UIElement.isProcessTrusted(withPrompt: true) {
                if let app = Application.allForBundleID("com.apple.findmy").first {
                    log("Found FindMy app")
                    do {
                        try app.setAttribute(.hidden, value: true)
                    } catch {
                        log("Cannot hide FindMy app: \(error)")
                    }
                }
            } else {
                log("No accessibility API permission")
            }
        }
        
        let homeDirectory = URL(fileURLWithPath: NSHomeDirectory())
        log("Home directory: " + homeDirectory.absoluteString)
        
        var hasAccess = true
        
        if items {
            let itemsJsonFile = homeDirectory.appending(path: "Library/Caches/com.apple.findmy.fmipcore/Items.data")
            log("Items file: " + itemsJsonFile.absoluteString)
            
            do {
                let data = try Data(contentsOf: itemsJsonFile, options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? [AnyObject] {
                    log("Got " + String(jsonResult.count) + " item(s):");
                    for item in jsonResult {
                        if let id = item["identifier"] as? String {
                            log("- Item " + id);
                            if let location = item["location"] as? [String: Any] {
                                if let latitude = location["latitude"] as? NSNumber,
                                   let longitude = location["longitude"] as? NSNumber,
                                   let accuracy = location["horizontalAccuracy"] as? NSNumber {
                                    log("- - Location: " + latitude.stringValue + ", " + longitude.stringValue + " (" + accuracy.stringValue + ")")
                                    
                                    updateEntity(id: id, latitude: latitude, longitude: longitude, accuracy: accuracy, battery: -1)
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
            let devicesJsonFile = homeDirectory.appending(path: "Library/Caches/com.apple.findmy.fmipcore/Devices.data")
            log("Devices file: " + devicesJsonFile.absoluteString)
            
            do {
                let data = try Data(contentsOf: devicesJsonFile, options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? [AnyObject] {
                    log("Got " + String(jsonResult.count) + " item(s):");
                    for item in jsonResult {
                        if let id = item["baUUID"] as? String {
                            log("- Item " + id);
                            if let location = item["location"] as? [String: Any] {
                                if let latitude = location["latitude"] as? NSNumber,
                                   let longitude = location["longitude"] as? NSNumber,
                                   let accuracy = location["horizontalAccuracy"] as? NSNumber {
                                    log("- - Location: " + latitude.stringValue + ", " + longitude.stringValue + " (" + accuracy.stringValue + ")")
                                    
                                    if let battery = item["batteryLevel"] as? NSNumber {
                                        log("- - Battery level: " + battery.stringValue)
                                        updateEntity(id: id, latitude: latitude, longitude: longitude, accuracy: accuracy, battery: battery)
                                    } else {
                                        log("- - No battery level provided")
                                        updateEntity(id: id, latitude: latitude, longitude: longitude, accuracy: accuracy, battery: -1)
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
            fileAccessDialogShowing = true
        }
        
        
        let interval: String = UserDefaults.standard.string(forKey: "endpoint_interval")!
        log("Scheduling next update after " + interval + " minutes");
        
        if let currentTimer = timer {
            currentTimer.invalidate()
        }
        self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(interval)! * 60, repeats: false) { t in
            fetchData()
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
                log("[" + id + "] Data sent: HTTP \(statusCode)")
            }
            else {
                log("[" + id + "] Data error: \(error!.localizedDescription)");
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
}

// Toggle Sidebar Function
func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
}
