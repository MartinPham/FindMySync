//
//  Backport.swift
//  FindMySync
//
//  Created by Martin Pham on 07/06/23.
//

import SwiftUI

struct CheckmarkView: View {
	var body: some View {
		if #available(macOS 11.0, *) {
			Image(systemName: "checkmark.circle")
				.foregroundColor(Color(NSColor.green))
				.font(.system(size: 20))
		} else {
			Circle()
				.frame(width: 20, height: 20)
				.foregroundColor(.green)
		}

	}
}

struct BackportLabel: View {
	let text: String
	let systemImage: String

	init(_ text: String, systemImage: String) {
		self.text = text
		self.systemImage = systemImage
	}

	var body: some View {
		if #available(macOS 11.0, *) {
			return AnyView(
				Label(text, systemImage: systemImage)
			)
		} else {
			return AnyView(
				Text(text)
			)
		}
	}
}

struct BackportLink<Content: View>: View {
	private let destination: URL
	private let content: Content

	init(destination: URL, @ViewBuilder content: () -> Content) {
		self.destination = destination
		self.content = content()
	}

	@ViewBuilder
	var body: some View {
		if #available(macOS 11.0, *) {
			Link(destination: destination, label: { content })
		} else {
			Button(action: {
				NSWorkspace.shared.open(destination)
			}) {
				content
			}
		}
	}
}

struct BackportText: NSViewRepresentable {
	private let text: String
	private let font: NSFont

	init(_ text: String, font: NSFont) {
		self.text = text
		self.font = font
	}

	func makeNSView(context: Context) -> NSTextField {
		let textField = NSTextField()
		textField.backgroundColor = .clear
		textField.font = font
		textField.isEditable = false
		textField.isSelectable = true
		textField.backgroundColor = NSColor.clear
		textField.stringValue = text
		textField.isBezeled = false
		textField.drawsBackground = false

		return textField
	}

	func updateNSView(_ nsView: NSTextField, context: Context) {
		nsView.stringValue = text
	}
}

struct Backport<Content> {
	let content: Content
}

extension Backport where Content: View {
	@ViewBuilder func Text_bold() -> some View {
		if #available(macOS 13.0, *) {
			content.bold()
		} else {
			content
		}
	}
	@ViewBuilder func TextField_fontWeight_semibold() -> some View {
		if #available(macOS 13.0, *) {
			content.fontWeight(.semibold)
		} else {
			content
		}
	}
	@ViewBuilder func TextField_onSubmit(_ action: @escaping (() -> Void)) -> some View {
		if #available(macOS 12.0, *) {
			content.onSubmit(action)
		} else {
			content
		}
	}

	@ViewBuilder func View_confirmationDialog(
		_ title: String, message: String, isPresented: Binding<Bool>,
		primaryButtonTitle: String, primaryAction: @escaping (() -> Void),
		secondaryButtonTitle: String, secondaryAction: @escaping (() -> Void)
	) -> some View {
		if #available(macOS 12.0, *) {

			content
				.confirmationDialog(title, isPresented: isPresented) {
					Button(primaryButtonTitle, action: primaryAction)
					Button(secondaryButtonTitle, action: secondaryAction)

				} message: {
					Text(message)
				}
		} else {
			content
				.alert(isPresented: isPresented) {
					Alert(
						title: Text(title),
						message: Text(message),
						primaryButton: .destructive(
							Text(primaryButtonTitle),
							action: primaryAction),
						secondaryButton: .cancel(
							Text(secondaryButtonTitle),
							action: secondaryAction)
					)
				}
		}
	}
}

extension View {
	var backport: Backport<Self> { Backport(content: self) }
}
