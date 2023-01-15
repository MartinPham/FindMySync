//
//  FindMySyncApp.swift
//  FindMySync
//
//  Created by ZZZ on 11/01/23.
//

import SwiftUI

@main
struct FindMySyncApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            SidebarView()
        }
    }
    
    init() {
        
        UserDefaults.standard.register(
            defaults: [
                "sources_devices": true,
                "sources_items": true,
                "sources_hideapp": true,
                "endpoint_url": "http://homeassistant.local:8123/api/services/device_tracker/see",
                "endpoint_auth": "Bearer <INSERT TOKEN HERE>",
                "endpoint_interval": "5",
            ]
        )
    }
}
