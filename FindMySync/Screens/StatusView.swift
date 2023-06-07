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
                            .lineSpacing(12)
                            .lineLimit(nil)
                            .frame(width: geometry.size.width)
                            .backport.Text_textSelection_enabled()
                        
                        
                    }
            
                }
        .padding()
        
        Spacer()
        HStack {
            Spacer()
            Button(action: {
                Synchronizer.shared.fetchData()
            }){
                HStack {
                    if #available(macOS 11.0, *) {
                        Image(systemName: "bolt")
                    }
                    
                    Text("Force update")
                }
            }.buttonStyle(PlainButtonStyle())
                .foregroundColor(.white)
                .font(.headline)
                .frame(width: 200, height: 40)
                .background(Color.blue)
                .cornerRadius(15)
            
            if #available(macOS 11.0, *) {
                Button(action: {
                    Synchronizer.shared.onAccessDenied()
                }){
                    HStack {
                        Image(systemName: "questionmark.circle")
                        
                        Text("Permissions")
                    }
                }.buttonStyle(PlainButtonStyle())
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(width: 200, height: 40)
                    .background(Color.blue)
                    .cornerRadius(15)
            }
            
            Spacer()
        }

        
        Spacer()
        Spacer()
    }
    
    
}

