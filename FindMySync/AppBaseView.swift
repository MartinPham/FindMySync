//
//  AppMenuView.swift
//  FindMySync
//
//  Created by Martin Pham on 07/06/23.
//

import SwiftUI

struct AppBaseView: View {
    var onAppear: () -> Void
	var dataDirectory: String
	@Binding var selection: Screen?
	@Binding var logs: String
	@Binding var config: String
	@Binding var directoryDialogShowing: Bool
	@Binding var fileAccessDialogShowing: Bool

	var body: some View {
		NavigationView {
			List {
				Text("SYNCHRONIZATION")
					.font(.system(size: 10))
					.fontWeight(.bold)

				NavigationLink(
					destination: HomeView(onDiscoverClick: {
						selection = .status
					}), tag: Screen.home, selection: $selection
				) {
					BackportLabel("Home", systemImage: "house")
				}

				NavigationLink(
					destination: StatusView(logs: $logs), tag: Screen.status,
					selection: $selection
				) {
					BackportLabel("Status", systemImage: "text.bubble")
				}

				Divider()

				Text("SETTINGS")
					.font(.system(size: 10))
					.fontWeight(.bold)

                
                if #available(macOS 14.4, *) {
                } else {
                    NavigationLink(
                        destination: DatasourcesView(), tag: Screen.data,
                        selection: $selection
                    ) {
                        BackportLabel("Data", systemImage: "rectangle.stack")
                    }
                }

				NavigationLink(
					destination: ServerEndpointView(), tag: Screen.endpoint,
					selection: $selection
				) {
					BackportLabel("Endpoint", systemImage: "globe")
				}

				NavigationLink(
					destination: ExtrasView(config: $config), tag: Screen.extra,
					selection: $selection
				) {
					BackportLabel("Extras", systemImage: "bolt.circle")
				}

				Divider()

				NavigationLink(
					destination: AboutView(), tag: Screen.about,
					selection: $selection
				) {
					BackportLabel("About", systemImage: "star")
				}
			}
			.listStyle(SidebarListStyle())
			.frame(minWidth: 100, idealWidth: 100, maxWidth: 300)

			HomeView {
				selection = .endpoint
			}
		}
		.backport.View_confirmationDialog(
			"FindMy data access",
			message:
				"FindMySync may need your permessions to access \(dataDirectory)",
			isPresented: $fileAccessDialogShowing,
			primaryButtonTitle: "Grant permissions",
			primaryAction: {
				fileAccessDialogShowing = false
				directoryDialogShowing = true
			}, secondaryButtonTitle: "Help",
			secondaryAction: {
				NSWorkspace.shared.open(
					URL(string: "https://www.martinpham.com/findmysync/")!)
			}
		)
		.onAppear(perform: onAppear)

	}
}
