//
//  ContentView.swift
//  SwiftApp
//
//  Created by Studente on 04/07/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        TabView {
            ScansioneView()
                .tabItem {
                    Image(systemName: "qrcode")
                        .font(.system(size: 46))
                }
            
            creaItinerarioView()
                .tabItem {
                    Image(systemName: "airplane")
                        .font(.system(size: 4))
                }
            
            ListaItinerariView()
                .tabItem {
                    Image(systemName: "map")
                        .font(.system(size: 4))
                }
        }.accentColor(.mint)
    }
}


#Preview {
    ContentView()
}
 
