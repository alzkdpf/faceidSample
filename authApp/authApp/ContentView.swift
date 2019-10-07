//
//  ContentView.swift
//  authApp
//
//  Created by Michael LIM on 07/10/2019.
//  Copyright © 2019 topco. All rights reserved.
//

import SwiftUI

import WebKit
  
struct WebView : UIViewRepresentable {
      
    let request: URLRequest
      
    func makeUIView(context: Context) -> WKWebView  {
        return WKWebView()
    }
      
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(request)
    }
      
}

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
            }
            

            Spacer()
        }
        .background(Color.red)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

#if DEBUG
struct WebView_Previews : PreviewProvider {
    static var previews: some View {
        WebView(request: URLRequest(url: URL(string: "https://www.apple.com")!))
    }
}
#endif 
