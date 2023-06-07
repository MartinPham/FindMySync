//
//  ServerEndpointView.swift
//  FindMySync
//
//  Created by ZZZ on 11/01/23.
//

import SwiftUI

struct ServerEndpointView: View {
    
    @State private var url: String = UserDefaults.standard.string(forKey: "endpoint_url")!
    @State private var auth: String = UserDefaults.standard.string(forKey: "endpoint_auth")!
        
    var body: some View {
        ScrollView {
            VStack {
                TextFieldView(
                    title: "URL",
                    value: $url,
                    subtitle: "Where data will be sent",
                    onChange: {
                        UserDefaults.standard.set(url, forKey: "endpoint_url")
                        
                        Synchronizer.shared.fetchData()
                    }
                )
                TextFieldView(
                    title: "Authorization header",
                    value: $auth,
                    subtitle: "Authorize request",
                    onChange: {
                        UserDefaults.standard.set(auth, forKey: "endpoint_auth")
                        
                        Synchronizer.shared.fetchData()
                    }
                )
            }
            .padding()
        }
    }
}
