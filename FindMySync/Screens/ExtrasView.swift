//
//  ExtrasView.swift
//  FindMySync
//
//  Created by ZZZ on 17/01/23.
//

import SwiftUI
import AXSwift
import UniformTypeIdentifiers

struct ExtrasView: View {
    @State private var interval: String = UserDefaults.standard.string(forKey: "extra_interval")!
    @State private var hide_findmy_app: Bool = UserDefaults.standard.bool(forKey: "extra_hide_findmy_app")
    @State private var generate_config: Bool = UserDefaults.standard.bool(forKey: "extra_generate_config")
    
    var body: some View {
        ScrollView {
            VStack {
                TextFieldView(
                    title: "Update interval",
                    value: $interval,
                    subtitle: "How many minutes each update",
                    onChange: {
                        var newInterval = Int(interval)
                        if newInterval == nil {
                            newInterval = Int(1)
                        }
                        interval = newInterval!.description
                        UserDefaults.standard.set(interval, forKey: "extra_interval")
                        
                        Synchronizer.shared.fetchData()
                    }
                )
                CheckboxView(
                    title: "Hide Find My app",
                    value: $hide_findmy_app,
                    subtitle: "Not showing Apple Find My app window",
                    onChange: {
                        hide_findmy_app.toggle()
                        UserDefaults.standard.set(hide_findmy_app, forKey: "extra_hide_findmy_app")
                        
                        if hide_findmy_app {
                            _ = UIElement.isProcessTrusted(withPrompt: true)
                        }
                        
                    }
                )
                CheckboxView(
                    title: "Generate Home Assistant config",
                    value: $generate_config,
                    subtitle: "Create config for FindMy devices on known_devices.yaml file",
                    onChange: {
                        generate_config.toggle()
                        UserDefaults.standard.set(generate_config, forKey: "extra_generate_config")
                        
                        Synchronizer.shared.fetchData()
                    }
                )
            }
            .padding()
        }
        
    }
}
