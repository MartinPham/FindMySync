//
//  DatasourcesView.swift
//  FindMySync
//
//  Created by ZZZ on 11/01/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct DatasourcesView: View {
	@State private var devices: Bool = UserDefaults.standard.bool(forKey: "sources_devices")
	@State private var items: Bool = UserDefaults.standard.bool(forKey: "sources_items")

	var body: some View {
		ScrollView {
			VStack {
				CheckboxView(
					title: "Synchronize Devices data",
					value: $devices, subtitle: "iPhone, iPad, iPod touch, Mac, and Apple Watch",
					onChange: {
						devices.toggle()

						UserDefaults.standard.set(
							devices, forKey: "sources_devices")

						Synchronizer.shared.fetchData()
					}
				)
				CheckboxView(
					title: "Synchronize Items data",
					value: $items,
					subtitle: "AirTag, and third-party items",
					onChange: {
						items.toggle()

						UserDefaults.standard.set(
							items, forKey: "sources_items")

						Synchronizer.shared.fetchData()
					}
				)
			}
			.padding()
		}

	}
}
