import SwiftUI

struct Tappa: Identifiable, Equatable, Codable {
    var id: UUID = UUID()
    var nome: String
    var descr: String
    var oraArrivo: String
    var foto: Image? = nil // Non codificabile, gestita separatamente
    var maps: String
    
    enum CodingKeys: String, CodingKey {
        case id, nome, descr, oraArrivo, maps
    }
    
    init(id: UUID = UUID(), nome: String, descr: String, oraArrivo: String, foto: Image? = nil, maps: String) {
        self.id = id
        self.nome = nome
        self.descr = descr
        self.oraArrivo = oraArrivo
        self.foto = foto
        self.maps = maps
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        nome = try container.decode(String.self, forKey: .nome)
        descr = try container.decode(String.self, forKey: .descr)
        oraArrivo = try container.decode(String.self, forKey: .oraArrivo)
        maps = try container.decode(String.self, forKey: .maps)
        foto = nil // Non decodificata da JSON
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(nome, forKey: .nome)
        try container.encode(descr, forKey: .descr)
        try container.encode(oraArrivo, forKey: .oraArrivo)
        try container.encode(maps, forKey: .maps)
        // foto non codificata
    }
} 