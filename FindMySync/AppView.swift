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
		if #available(macOS 11.0, *) {
			AppBaseView(
				onAppear: onAppear,
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
				switch result {

				case .success(let url):
					guard url.startAccessingSecurityScopedResource() else {
						return
					}

					defer { url.stopAccessingSecurityScopedResource() }

					do {
						@AppStorage("bookmarkData") var findmyBookmark =
							try url.bookmarkData(
								options: .minimalBookmark,
								includingResourceValuesForKeys: nil,
								relativeTo: nil)

						Synchronizer.shared.fetchData()
					} catch {
						log("Bookmark error \(error)")
					}
				case .failure(let error):
					log("Importer error: \(error)")
				}
				directoryDialogShowing = false
			}

		} else {
			AppBaseView(
				onAppear: onAppear,
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

	func onAppear() {
		Synchronizer.shared.log = log
		Synchronizer.shared.logConfig = logConfig
		Synchronizer.shared.clearLog = clearLog
		Synchronizer.shared.onAccessDenied = {
			fileAccessDialogShowing = true
		}
		Synchronizer.shared.fetchData()
	}

}
