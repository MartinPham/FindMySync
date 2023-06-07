//
//  AppMenuView.swift
//  FindMySync
//
//  Created by Martin Pham on 07/06/23.
//

import SwiftUI


struct AppMenuView: View {
    @Binding var selection: Screen?
    @Binding var logs: String
    @State private var directoryDialogShowing = false
    @State private var fileAccessDialogShowing = false
    
    var body: some View {
        List {
            Text("SYNCHRONIZATION")
                .font(.system(size: 10))
                .fontWeight(.bold)
            
                NavigationLink(destination: HomeView(onDiscoverClick: {
                    selection = .status
                }), tag: Screen.home, selection: $selection) {
                    BackportLabel("Home", systemImage: "house")
                }
                
                NavigationLink(destination: StatusView(logs: $logs), tag: Screen.status, selection: $selection) {
                    BackportLabel("Status", systemImage: "text.bubble")
                }
            
            
            Divider()
            
            Text("SETTINGS")
                .font(.system(size: 10))
                .fontWeight(.bold)
            
                NavigationLink(destination: DatasourcesView(), tag: Screen.data, selection: $selection) {
                    BackportLabel("Data", systemImage: "rectangle.stack")
                }
                
                NavigationLink(destination: ServerEndpointView(), tag: Screen.endpoint, selection: $selection) {
                    BackportLabel("Endpoint", systemImage: "globe")
                }
                
                NavigationLink(destination: ExtrasView(), tag: Screen.extra, selection: $selection) {
                    BackportLabel("Extras", systemImage: "bolt.circle")
                }
            
            
            Divider()
            
            NavigationLink(destination: AboutView(), tag: Screen.about, selection: $selection) {
                BackportLabel("About", systemImage: "star")
            }
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 100, idealWidth: 100, maxWidth: 300)
        
    }
}
