//
//  TextFieldView.swift
//  FindMySync
//
//  Created by Martin Pham on 07/06/23.
//

import SwiftUI

struct TextFieldView: View {
	var title: String
	@Binding var value: String
	var subtitle: String
	var onChange: () -> Void

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
				TextField("...", text: $value, onCommit: onChange)
					.font(.system(.title, design: .rounded))
					.textFieldStyle(PlainTextFieldStyle())
					.backport.TextField_onSubmit {
						onChange()
					}
					.backport.TextField_fontWeight_semibold()
				Spacer()
			}
		}
		.padding()
		.background(Color(NSColor.controlBackgroundColor))
		.cornerRadius(12)
	}
}
