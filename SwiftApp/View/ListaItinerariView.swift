import SwiftUI

enum Categoria {
    case cibo, monumenti, natura, shopping
}

struct Itinerario: Identifiable, Equatable {
    var id = UUID()
    var citta: String
    var aeroporto: String
    var ore: Int
    var minuti: Int
    var categoria: Categoria
    var preferito: Bool = false
    
    func testo() -> String {
        if self.minuti < 10 {
            return "\(citta) - \(ore):0\(minuti) ore"
        } else {
            return "\(citta) - \(ore):\(minuti) ore"
        }
    }
}

struct ListaItinerariView: View {
    @State private var itinerari: [Itinerario] = [
        Itinerario(citta: "Barcellona", aeroporto: "Aeropuertos de Barcelona", ore: 6, minuti: 0, categoria: .monumenti),
        Itinerario(citta: "Napoli", aeroporto: "Capodichino", ore: 2, minuti: 30, categoria: .cibo, preferito: true),
        Itinerario(citta: "Parigi", aeroporto: "Aeroporté de Paris", ore: 8, minuti: 20, categoria: .shopping)
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(itinerari) { itinerario in
                    NavigationLink(destination: ItinerarioView()) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(itinerario.testo())
                                Text("\(itinerario.categoria)")
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            if itinerario.preferito {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.mint)
                            }
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button {
                            togglePreferito(itinerario)
                        } label: {
                            Label("Preferiti", systemImage: itinerario.preferito ? "star.fill" : "star")
                        }
                        .tint(.mint)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            eliminaItinerario(itinerario)
                        } label: {
                            Label("Elimina", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Itinerari")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Azioni
    
    func togglePreferito(_ item: Itinerario) {
        if let index = itinerari.firstIndex(of: item) {
            itinerari[index].preferito.toggle()
        }
    }
    
    func eliminaItinerario(_ item: Itinerario) {
        if let index = itinerari.firstIndex(of: item) {
            itinerari.remove(at: index)
        }
    }
    
}


#Preview {
    ListaItinerariView()
}
