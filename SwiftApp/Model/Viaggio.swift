import Foundation

struct Viaggio: Identifiable, Codable, Equatable {
    let id: UUID
    let partenza: String
    let destinazione: String
    let scalo: String
    let dataCreazione: Date
    let itinerario: String
    
    init(partenza: String, destinazione: String, scalo: String = "Scalo", itinerario: String = "Itinerario generato", dataCreazione: Date = Date()) {
        self.id = UUID()
        self.partenza = partenza
        self.destinazione = destinazione
        self.scalo = scalo
        self.dataCreazione = dataCreazione
        self.itinerario = itinerario
    }
} 