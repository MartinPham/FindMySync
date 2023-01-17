//
//  StatusView.swift
//  FindMySync
//
//  Created by ZZZ on 11/01/23.
//

import SwiftUI

struct StatusView: View {
    @Binding var logs: String
    
    var body: some View {
        GeometryReader { geometry in
                    ScrollView {
                        Text(logs)
                            .font(.custom("Courier", size: 14))
                            .textSelection(.enabled)
                            .lineSpacing(12)
                            .lineLimit(nil)
                            .frame(width: geometry.size.width)
                    }
                }
        .padding()
        .toolbar {
            Button(action: {
                Synchronizer.shared.fetchData()
            }) {
                HStack {
                    Image(systemName: "bolt")
                    Text("Force update")
                }
            }
        }
        .navigationTitle("Logs")
    }
}
