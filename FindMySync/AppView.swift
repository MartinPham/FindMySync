//
//  SidebarView.swift
//  FindMySync
//
//  Created by ZZZ on 11/01/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct AppView: View {
	@State var selection: Screen? = .home
	@State var logs = ""
	@State var config = ""

	@State var directoryDialogShowing = false
	@State var fileAccessDialogShowing = false

	var body: some View {
		if #available(macOS 14.4, *) {
            AppBaseView(
                onAppear: onAppear, dataDirectory: "~/Library/com.apple.icloud.searchpartyd",
                selection: $selection,
                logs: $logs,
                config: $config,
                directoryDialogShowing: $directoryDialogShowing,
                fileAccessDialogShowing: $fileAccessDialogShowing
            )
            .fileImporter(
                isPresented: $directoryDialogShowing,
                allowedContentTypes: [UTType.folder]
            ) { result in
                onDirectoryPicked(result)
            }
        } else if #available(macOS 11.0, *) {
			AppBaseView(
                onAppear: onAppear, dataDirectory: "~/Library/Caches/com.apple.findmy.fmipcore",
				selection: $selection,
				logs: $logs,
				config: $config,
				directoryDialogShowing: $directoryDialogShowing,
				fileAccessDialogShowing: $fileAccessDialogShowing
			)
			.fileImporter(
				isPresented: $directoryDialogShowing,
				allowedContentTypes: [UTType.folder]
			) { result in
				onDirectoryPicked(result)
			}

		} else {
			AppBaseView(
                onAppear: onAppear, dataDirectory: "~/Library/Caches/com.apple.findmy.fmipcore",
				selection: $selection,
				logs: $logs,
				config: $config,
				directoryDialogShowing: $directoryDialogShowing,
				fileAccessDialogShowing: $fileAccessDialogShowing
			)
		}
	}

	func log(_ message: String) {
		debugPrint(message)
		self.logs += message + "\n\n"
	}

	func logConfig(_ config: String) {
		debugPrint(config)
		self.config = config
	}

	func clearLog() {
		self.logs = ""
	}

	/// Stores the folder the user picked, so the grant survives this launch and
	/// the next one.
	func onDirectoryPicked(_ result: Result<URL, Error>) {
		switch result {
		case .success(let url):
			do {
				try DataAccess.grant(url)
				Synchronizer.shared.fetchData()
			} catch {
				log("Bookmark error \(error)")
			}
		case .failure(let error):
			log("Importer error: \(error)")
		}
		directoryDialogShowing = false
	}

	func onAppear() {
		Synchronizer.shared.log = log
		Synchronizer.shared.logConfig = logConfig
		Synchronizer.shared.clearLog = clearLog
		Synchronizer.shared.onAccessDenied = {
			fileAccessDialogShowing = true
		}

		// Reopen a folder picked on an earlier launch before reading anything.
		if DataAccess.restore() {
			log("Restored access to the FindMy folder")
		}

		Synchronizer.shared.fetchData()
	}

}
