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
                }
            
            creaItinerarioView()
                .tabItem {
                    Image(systemName: "airplane")
                }
            
            ListaItinerariView()
                .tabItem {
                    Image(systemName: "map")
                }
        }
    }
}


#Preview {
    ContentView()
}
