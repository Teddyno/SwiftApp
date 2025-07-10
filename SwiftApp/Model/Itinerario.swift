import SwiftUI

struct Itinerario: Identifiable, Equatable {
    var id = UUID()
    var citta: String
    var aeroporto: String
    var ore: Int
    var minuti: Int
    var categoria: Categoria
    var preferito: Bool = false
    var tappe: [Tappa]
    
    func testo() -> String {
        if self.minuti < 10 {
            return "\(citta) - \(ore):0\(minuti) ore"
        } else {
            return "\(citta) - \(ore):\(minuti) ore"
        }
    }
} 
