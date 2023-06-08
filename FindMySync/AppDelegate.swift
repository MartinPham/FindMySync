//
//  AppDelegate.swift
//  FindMySync
//
//  Created by zzz on 6/7/23.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {

	var window: NSWindow!

	func applicationDidFinishLaunching(_ aNotification: Notification) {

		UserDefaults.standard.register(
			defaults: [
				"sources_devices":
					true,
				"sources_items":
					true,
				"endpoint_url":
					"http://homeassistant.local:8123/api/services/device_tracker/see",
				"endpoint_auth":
					"Bearer <INSERT TOKEN HERE>",
				"extra_interval":
					"5",
				"extra_hide_findmy_app":
					false,
				"extra_generate_config":
					false,
			]
		)

		// Create the window and set the content view.
		window = NSWindow(
			contentRect:
				NSRect(
					x:
						0,
					y:
						0,
					width:
						800,
					height:
						600
				),
			styleMask: [
				.titled,
				.closable,
				.miniaturizable,
				.resizable,
				.fullSizeContentView,
			],
			backing:
				.buffered,
			defer:
				false
		)
		window.isReleasedWhenClosed = false
		window.center()
		window.setFrameAutosaveName(
			"FindMySync"
		)
		window.titlebarAppearsTransparent =
			true
		window.makeKeyAndOrderFront(nil)

		// Create the SwiftUI view that provides the window contents.
		window.contentView = NSHostingView(
			rootView:
				AppView()
		)

	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

}
