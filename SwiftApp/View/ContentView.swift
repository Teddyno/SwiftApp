//
//  ContentView.swift
//  SwiftApp
//
//  Created by Studente on 04/07/25.
//

import SwiftUI
import CoreData

class RootState: ObservableObject {
    @Published var selectedTab: Int = 1
    @Published var scaloPrecompilato: String = ""
}

struct ContentView: View {
    @StateObject private var rootState = RootState()

    var body: some View {
        TabView(selection: $rootState.selectedTab) {
            ScansioneView()
                .tabItem { Image(systemName: "qrcode") }
                .tag(0)
            creaItinerarioView()
                .tabItem { Image(systemName: "airplane.arrival") }
                .tag(1)
            ListaItinerariView()
                .tabItem { Image(systemName: "map") }
                .tag(2)
        }
        .accentColor(.mint)
        .environmentObject(rootState)
    }
}


#Preview {
    ContentView()
}
 
