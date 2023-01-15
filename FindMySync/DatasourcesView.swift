//
//  DatasourcesView.swift
//  FindMySync
//
//  Created by ZZZ on 11/01/23.
//

import SwiftUI

struct DatasourcesView: View {
    @State private var devices: Bool = UserDefaults.standard.bool(forKey: "sources_devices")
    @State private var items: Bool = UserDefaults.standard.bool(forKey: "sources_items")
    
    @State private var sources_hideapp: Bool = UserDefaults.standard.bool(forKey: "sources_hideapp")
    
    var body: some View {
        ScrollView {
            VStack {
                SourceField(
                    title: "Synchronizing Devices data",
                    value: $devices, subtitle: "iPhones, iPads, Macbooks, ...",
                    onClick: {
                        devices.toggle()
                        
                        UserDefaults.standard.set(devices, forKey: "sources_devices")
                    }
                )
                SourceField(
                    title: "Synchronizing Items data",
                    value: $items,
                    subtitle: "Airtags and other tracking items",
                    onClick: {
                        items.toggle()
                        
                        UserDefaults.standard.set(items, forKey: "sources_items")
                    }
                )
                SourceField(
                    title: "Hiding Find My app",
                    value: $items,
                    subtitle: "Not showing Apple Find My app window",
                    onClick: {
                        sources_hideapp.toggle()
                        
                        UserDefaults.standard.set(sources_hideapp, forKey: "sources_hideapp")
                    }
                )
            }
            .padding()
        }
        .navigationTitle("Datasources setting")
        
    }
}

struct SourceField: View {
    var title: String
    @Binding var value: Bool
    @State var isHovering: Bool = false
    var subtitle: String
    var onClick: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(title)
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(NSColor.systemPink))
                Spacer()
                
                if value {
                    Group {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(Color(NSColor.green))
                            .font(.system(size: 20))
                    }
                    .font(.callout)
                }
            }
            HStack(spacing: 6) {
                Group {
                    Text(subtitle)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(isHovering ? Color(NSColor.controlBackgroundColor).opacity(0.5) : Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .onTapGesture {
            onClick()
        }
        .onHover { over in
            isHovering = over
        }
    }
}
