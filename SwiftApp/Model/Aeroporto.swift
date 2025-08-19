//
//  Aeroporto.swift
//  SwiftApp
//
//  Created by teddy on 17/07/25.
//

import Foundation

struct Aeroporto: Codable, Identifiable {
    let name: String
    let city: String
    let iata: String
    let country: String
    // Minimo consigliato (in ore) per poter uscire dall'aeroporto durante lo scalo
    let min: Int?
    
    var id: String { iata } // Usa IATA come identificatore univoco
    
    var displayName: String {
        "\(city) (\(iata)) - \(name)"
    }
}

func caricaAeroporti() -> [Aeroporto] {
    guard let url = Bundle.main.url(forResource: "aeroporti", withExtension: "json") else {
        print("File aeroporti.json non trovato.")
        return []
    }
    do {
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode([Aeroporto].self, from: data)
        return decoded
    } catch {
        print("Errore nel caricamento degli aeroporti: \(error)")
        return []
    }
}


