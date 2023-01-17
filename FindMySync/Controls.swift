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
                TextField("...", text: $value)
                    .font(.system(.title, design: .rounded))
//                        .fontWeight(.semibold)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onSubmit {
                        onChange()
                    }
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

