import SwiftUI

enum Categoria: String, Codable {
    case cibo, monumenti, natura, shopping
}

struct Itinerario: Identifiable, Equatable, Codable {
    var id: UUID = UUID()
    var citta: String
    var aeroporto: String
    var ore: Int
    var minuti: Int
    var categoria: Categoria
    var preferito: Bool = false
    var tappe: [Tappa]
    var orarioArrivoScalo: String? = nil
    
    func testo() -> String {
        if self.minuti < 10 {
            return "\(citta) - \(ore):0\(minuti) ore"
        } else {
            return "\(citta) - \(ore):\(minuti) ore"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, citta, aeroporto, ore, minuti, categoria, preferito, tappe, orarioArrivoScalo
    }
    
    init(id: UUID = UUID(), citta: String, aeroporto: String, ore: Int, minuti: Int, categoria: Categoria, preferito: Bool = false, tappe: [Tappa], orarioArrivoScalo: String? = nil) {
        self.id = id
        self.citta = citta
        self.aeroporto = aeroporto
        self.ore = ore
        self.minuti = minuti
        self.categoria = categoria
        self.preferito = preferito
        self.tappe = tappe
        self.orarioArrivoScalo = orarioArrivoScalo
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        citta = try container.decode(String.self, forKey: .citta)
        aeroporto = try container.decode(String.self, forKey: .aeroporto)
        ore = try container.decode(Int.self, forKey: .ore)
        minuti = try container.decode(Int.self, forKey: .minuti)
        categoria = try container.decode(Categoria.self, forKey: .categoria)
        preferito = (try? container.decode(Bool.self, forKey: .preferito)) ?? false
        tappe = try container.decode([Tappa].self, forKey: .tappe)
        orarioArrivoScalo = try? container.decodeIfPresent(String.self, forKey: .orarioArrivoScalo)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(citta, forKey: .citta)
        try container.encode(aeroporto, forKey: .aeroporto)
        try container.encode(ore, forKey: .ore)
        try container.encode(minuti, forKey: .minuti)
        try container.encode(categoria, forKey: .categoria)
        try container.encode(preferito, forKey: .preferito)
        try container.encode(tappe, forKey: .tappe)
        try container.encodeIfPresent(orarioArrivoScalo, forKey: .orarioArrivoScalo)
    }
} 


