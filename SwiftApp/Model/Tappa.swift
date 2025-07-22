import SwiftUI
import CoreLocation

struct Tappa: Identifiable, Equatable, Codable {
    var id: UUID = UUID()
    var nome: String
    var descr: String
    var oraArrivo: String
    var maps: String
    var foto: String
    var latitudine:CLLocationDegrees
    var longitudine:CLLocationDegrees
    
    enum CodingKeys: String, CodingKey {
        case id, nome, descr, oraArrivo, maps, foto, latitudine, longitudine
    }
    
    init(id: UUID = UUID(), nome: String, descr: String, oraArrivo: String, foto: String, maps: String,latitudine:CLLocationDegrees, longitudine:CLLocationDegrees) {
        self.id = id
        self.nome = nome
        self.descr = descr
        self.oraArrivo = oraArrivo
        self.foto = foto
        self.maps = maps
        self.latitudine = latitudine
        self.longitudine = longitudine
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        nome = try container.decode(String.self, forKey: .nome)
        descr = try container.decode(String.self, forKey: .descr)
        oraArrivo = try container.decode(String.self, forKey: .oraArrivo)
        maps = try container.decode(String.self, forKey: .maps)
        foto = try container.decode(String.self, forKey: .foto)
        latitudine=try container.decode(CLLocationDegrees.self, forKey: .latitudine)
        longitudine=try container.decode(CLLocationDegrees.self, forKey: .longitudine)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(nome, forKey: .nome)
        try container.encode(descr, forKey: .descr)
        try container.encode(oraArrivo, forKey: .oraArrivo)
        try container.encode(maps, forKey: .maps)
        try container.encode(foto, forKey: .foto)
        try container.encode(latitudine, forKey: .latitudine)
        try container.encode(longitudine, forKey: .longitudine)
    }
} 
