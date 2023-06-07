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
            AppView()
        }
    }
    
    init() {
        
        UserDefaults.standard.register(
            defaults: [
                "sources_devices": true,
                "sources_items": true,
                "endpoint_url": "http://homeassistant.local:8123/api/services/device_tracker/see",
                "endpoint_auth": "Bearer <INSERT TOKEN HERE>",
                "extra_interval": "5",
                "extra_hide_findmy_app": false,
                "extra_generate_config": false,
            ]
        )
    }
}
