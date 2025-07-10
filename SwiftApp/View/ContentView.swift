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
    @State private var itinerari: [Itinerario] = []
    
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
            
            ListaItinerariView(itinerari: $itinerari)
                .tabItem {
                    Image(systemName: "map")
                }.tag(2)
        }
        .accentColor(.mint)
        .onAppear {
            loadItinerariCreatiFromJSON()
            itinerari.sort { $0.preferito && !$1.preferito }
        }
    }
    
    func loadItinerariCreatiFromJSON() {
        if let url = Bundle.main.url(forResource: "itinerariCreati", withExtension: "json") {
            print("Trovato file JSON: \(url)")
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decoded = try decoder.decode([Itinerario].self, from: data)
                itinerari = decoded
                print("Itinerari caricati: \(itinerari)")
            } catch {
                print("Errore nel caricamento degli itinerari: \(error)")
            }
        } else {
            print("File JSON degli itinerari non trovato.")
        }
    }
}


#Preview {
    ContentView()
}
 
