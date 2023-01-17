//
//  SidebarView.swift
//  FindMySync
//
//  Created by ZZZ on 11/01/23.
//

import SwiftUI
import AXSwift
import UniformTypeIdentifiers

struct AppView: View {
    @State var selection: Screen? = .home
    @State var logs = ""
    
    @AppStorage("bookmarkData") var findmyBookmark: Data?
    
    @State private var directoryDialogShowing = false
    @State private var fileAccessDialogShowing = false
    
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
                    NavigationLink(destination: StatusView(logs: $logs), tag: Screen.status, selection: $selection) {
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
                    NavigationLink(destination: ExtrasView(), tag: Screen.extra, selection: $selection) {
                        Label("Extras", systemImage: "bolt.circle")
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
                    
                    Synchronizer.shared.fetchData()
                } catch {
                    log("Bookmark error \(error)")
                }
            case .failure(let error):
                log("Importer error: \(error)")
            }
            directoryDialogShowing = false
        }
    }
    
    func log(_ message: String) {
        debugPrint(message)
        self.logs += message + "\n"
    }
    
    func clearLog() {
        self.logs = ""
    }
    
    func onAppear() {
        Synchronizer.shared.log = log
        Synchronizer.shared.clearLog = clearLog
        Synchronizer.shared.onAccessDenied = {
            fileAccessDialogShowing = true
        }
        Synchronizer.shared.fetchData()
    }
    
    
    
}

// Toggle Sidebar Function
func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
}
