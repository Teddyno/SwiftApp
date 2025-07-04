//
//  ContentView.swift
//  SwiftApp
//
//  Created by Studente on 04/07/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @State private var selectedTab: Int = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ScansioneView()
                .tabItem {
                    Image(systemName: "qrcode")
                }.tag(0)
            
            creaItinerarioView()
                .tabItem {
                    Image(systemName: "airplane.arrival")
                }.tag(1)
            
            ListaItinerariView()
                .tabItem {
                    Image(systemName: "map")
                }.tag(2)
        }.accentColor(.mint)
    }
}


#Preview {
    ContentView()
}
 
