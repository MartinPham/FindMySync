//
//  CheckboxView.swift
//  FindMySync
//
//  Created by Martin Pham on 07/06/23.
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
                        CheckmarkView()
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
