//
//  SidebarView.swift
//  FindMySync
//
//  Created by ZZZ on 11/01/23.
//

import SwiftUI
import UniformTypeIdentifiers



@available(macOS 11.0, *)
struct AppView: View {
    @State var selection: Screen? = .home
    @State var logs = ""
    
    @AppStorage("bookmarkData") var findmyBookmark: Data?
    
    @State private var directoryDialogShowing = false
    @State private var fileAccessDialogShowing = false
    
    var body: some View {
        NavigationView {
            AppMenuView(selection: $selection, logs: $logs)
            
            HomeView {
                selection = .endpoint
            }
        }
        .onAppear(perform: onAppear)
        .backport.View_confirmationDialog("FindMy data access", message: "FindMySync may need your permessions to access ~/Library/Caches/com.apple.findmy.fmipcore", isPresented: $fileAccessDialogShowing, primaryButtonTitle: "Grant permissions", primaryAction: {
            fileAccessDialogShowing = false
            directoryDialogShowing = true
        }, secondaryButtonTitle: "Help", secondaryAction: {
            NSWorkspace.shared.open(URL(string: "https://www.martinpham.com/findmysync/")!)
        })
        
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


struct LegacyAppView: View {
    @State var selection: Screen? = .home
    @State var logs = ""
    
    
    @State private var fileAccessDialogShowing = false
    
    var body: some View {
        NavigationView {
            AppMenuView(selection: $selection, logs: $logs)
            
            HomeView {
                selection = .endpoint
            }
        }
        .onAppear(perform: onAppear)
        
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

