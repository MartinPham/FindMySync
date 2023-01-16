//
//  ServerEndpointView.swift
//  FindMySync
//
//  Created by ZZZ on 11/01/23.
//

import SwiftUI

struct ServerEndpointView: View {
    
    @State private var interval: String = UserDefaults.standard.string(forKey: "endpoint_interval")!
    @State private var url: String = UserDefaults.standard.string(forKey: "endpoint_url")!
    @State private var auth: String = UserDefaults.standard.string(forKey: "endpoint_auth")!
        
        var body: some View {
            ScrollView {
                VStack {
                    EndpointField(title: "Update interval", value: $interval, subtitle: "How many minutes each update")
                    EndpointField(title: "URL", value: $url, subtitle: "Where data will be sent")
                    EndpointField(title: "Authorization header", value: $auth, subtitle: "Authorize request")
                }
                .padding()
            }
            .navigationTitle("Endpoint setting")
            
            .toolbar {
                Button(action: {
                    var newInterval = Int(interval)
                    if newInterval == nil {
                        newInterval = Int(1)
                    }
                    interval = newInterval!.description
                    UserDefaults.standard.set(interval, forKey: "endpoint_interval")
                    UserDefaults.standard.set(url, forKey: "endpoint_url")
                    UserDefaults.standard.set(auth, forKey: "endpoint_auth")
                }) {
                    HStack {
                        Image(systemName: "pencil.line")
                        Text("Save")
                    }
                }
            }
        }
    }

    struct EndpointField: View {
        var title: String
        @Binding var value: String
        var subtitle: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Group {
                        Text(title)
                            .font(.headline)
                    }
                    .foregroundColor(Color(NSColor.systemPink))
                    
                    Spacer()
                    
                    Group {
                        Text(subtitle)
                    }
                    .font(.callout)
                    .foregroundColor(.secondary)
                }
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    TextField("...", text: $value)
                        .font(.system(.title, design: .rounded))
//                        .fontWeight(.semibold)
                        .textFieldStyle(PlainTextFieldStyle())
                    Spacer()
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
        }
    }


extension NSTextField {
        open override var focusRingType: NSFocusRingType {
                get { .none }
                set { }
        }
}
