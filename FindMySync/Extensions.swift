//
//  Controls.swift
//  FindMySync
//
//  Created by ZZZ on 17/01/23.
//

import SwiftUI


struct CheckboxView: View {
    var title: String
    @Binding var value: Bool
    @State var isHovering: Bool = false
    var subtitle: String
    var onChange: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(title)
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(NSColor.systemPink))
                Spacer()
                
                if value {
                    Group {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(Color(NSColor.green))
                            .font(.system(size: 20))
                    }
                    .font(.callout)
                }
            }
            HStack(spacing: 6) {
                Group {
                    Text(subtitle)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(isHovering ? Color(NSColor.controlBackgroundColor).opacity(0.5) : Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .onTapGesture {
            onChange()
        }
        .onHover { over in
            isHovering = over
        }
    }
}



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


extension NSTextField {
    open override var focusRingType: NSFocusRingType {
            get { .none }
            set { }
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
    @ViewBuilder func Text_textSelection_enabled() -> some View {
        if #available(macOS 12.0, *) {
            content.textSelection(.enabled)
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
    @ViewBuilder func View_confirmationDialog(_ title: String, message: String, isPresented: Binding<Bool>, primaryButtonTitle: String, primaryAction: @escaping (() -> Void), secondaryButtonTitle: String, secondaryAction: @escaping (() -> Void)) -> some View {
        if #available(macOS 12.0, *) {
            content
                .confirmationDialog(title, isPresented: isPresented) {
                    Button(primaryButtonTitle,action: primaryAction)
                    Button(secondaryButtonTitle,action: secondaryAction)
                    
                } message: {
                    Text(message)
                }
        } else {
            content
                .alert(isPresented: isPresented) {
                    Alert(
                        title: Text(title),
                        message: Text(message),
                        primaryButton: .destructive(Text(primaryButtonTitle), action: primaryAction),
                        secondaryButton: .cancel(Text(secondaryButtonTitle), action: secondaryAction)
                    )
                }
        }
    }
}


extension View {
    var backport: Backport<Self> { Backport(content: self) }
}
