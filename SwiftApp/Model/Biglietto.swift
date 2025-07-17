import Foundation

struct Biglietto: Identifiable, Codable, Equatable {
    let id: UUID
    let contenuto: String
    let dataScansione: Date
    
    init(contenuto: String, dataScansione: Date = Date()) {
        self.id = UUID()
        self.contenuto = contenuto
        self.dataScansione = dataScansione
    }
} 