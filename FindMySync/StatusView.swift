//
//  StatusView.swift
//  FindMySync
//
//  Created by ZZZ on 11/01/23.
//

import SwiftUI

struct StatusView: View {
    @Binding var logs: String
    var onForceUpdateClick: () -> Void
    
    var body: some View {
        VStack {
            Text(logs)
        }
        .padding()
        .toolbar {
            Button(action: {
                onForceUpdateClick()
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
