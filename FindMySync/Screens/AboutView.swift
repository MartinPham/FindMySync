//
//  AboutView.swift
//  FindMySync
//
//  Created by ZZZ on 11/01/23.
//

import SwiftUI

struct AboutView: View {
    
    var body: some View {
        VStack {
            VStack {
                ZStack(alignment: .top) {
                    Image("background")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Rectangle())
                        .frame(height: 200)
                    
                    Image("me")
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(radius: 10)
                        .padding(EdgeInsets(top: 100, leading: 0, bottom: 0, trailing: 0))
                }
                
                VStack(spacing: 15) {
                        VStack(spacing: 5) {
                            Text("Martin Pham")
                                .bold()
                                .font(.title)
                            Text("Just another boring developer")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }.padding()
                    Text("Hey, I love ~~funny~~ boring stuffs!")
                        .font(.title)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        .multilineTextAlignment(.center)
                    Text("Writing softwares, hacking hardwares, researching new things,... you name it.")
                        .multilineTextAlignment(.center)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
                        .multilineTextAlignment(.center)
                    Text("Interested? Check my stuffs here")
                        .multilineTextAlignment(.center)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        .backport.Text_bold()
                    HStack {
                        BackportLink(destination: URL(string: "https://www.martinpham.com")!) {
                            Image("web").resizable().aspectRatio(contentMode: .fit).frame(width: 100).padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                        }
                        BackportLink(destination: URL(string: "https://gitlab.com/martinpham")!) {
                            Image("gitlab").resizable().aspectRatio(contentMode: .fit).frame(width: 100).padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                        }
                        BackportLink(destination: URL(string: "https://github.com/martinpham")!) {
                            Image("github").resizable().aspectRatio(contentMode: .fit).frame(width: 100).padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                        }
                        BackportLink(destination: URL(string: "https://hub.docker.com/u/martinpham")!) {
                            Image("docker").resizable().aspectRatio(contentMode: .fit).frame(width: 100).padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                        }
                    }
                    Spacer()
                }
            }
            Spacer()
        }
    }
}
