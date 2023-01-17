//
//  HomeView.swift
//  FindMySync
//
//  Created by ZZZ on 11/01/23.
//

import SwiftUI
import MapKit


struct HomeView: View {
    var onDiscoverClick: () -> Void
    var body: some View {
        VStack {
                Text("Synchronize FindMy data")
                    .fontWeight(.heavy)
                    .font(.system(size: 50))
                    .padding(EdgeInsets(top: 40, leading: 0, bottom: 0, trailing: 0))
        
                
                VStack(alignment: .leading) {
                    FeatureView(image: "location.magnifyingglass", imageColor: .green, title: "Updating data continuously", description: "Supports both devices and items data, including iPhones, iPads, Airtags,...")
                    FeatureView(image: "globe", imageColor: .red, title: "Flexible destination endpoint", description: "Config synchronization's URL endpoint, with Authorization header")
                    FeatureView(image: "star", imageColor: .blue, title: "One more thing..", description: "Sorry.. I forgot what to say here, will update you later")
                }
                .padding()
            
            
            Button(action: {
                onDiscoverClick()
            }){
            Text("Discover")
                .foregroundColor(.white)
                .font(.headline)
                .frame(width: 200, height: 40)
                .background(Color.blue)
                .cornerRadius(15)
            }.buttonStyle(PlainButtonStyle())
            Spacer()
            
        }
        
        .navigationTitle(title())
        .toolbar {
            Button(action: {
                NSWorkspace.shared.open(URL(string: "https://www.martinpham.com/findmysync/")!)
            }) {
                HStack {
                    Image(systemName: "questionmark.circle")
                    Text("Help")
                }
            }
        }
    }
    
    func title() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "FindMySync (version \(version)-\(build))"
    }
}

struct FeatureView: View {
    var image: String
    var imageColor: Color
    var title: String
    var description: String

    var body: some View {
        HStack(alignment: .center) {
            HStack {
                Image(systemName: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .font(.system(size: 50))
                    .frame(width: 50)
                    .foregroundColor(imageColor)
                    .padding()

                VStack(alignment: .leading) {
                    Text(title).bold()
                
                    Text(description)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0))
                }
            }.frame(height: 100)
        }
    }
}
