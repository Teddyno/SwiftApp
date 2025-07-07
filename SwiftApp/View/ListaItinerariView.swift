import SwiftUI

enum Categoria {
    case cibo, monumenti, natura, shopping
}

struct Tappa:Identifiable,Equatable{
    var id=UUID()
    var nome:String
    var descr:String
    var oraArrivo:String
    var foto:Image
    var maps:String
}

struct Itinerario: Identifiable,Equatable {
    var id = UUID()
    var citta: String
    var aeroporto: String
    var ore: Int
    var minuti: Int
    var categoria: Categoria
    var preferito: Bool = false
    var tappe:[Tappa]
    
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
        Itinerario(citta: "Barcellona", aeroporto: "Aeropuertos de Barcelona", ore: 6, minuti: 0, categoria: .monumenti,tappe:[]),
        Itinerario(citta: "Napoli", aeroporto: "Capodichino", ore: 2, minuti: 30, categoria: .cibo, preferito: true,tappe:[]),
        Itinerario(citta: "Parigi", aeroporto: "Aeroporté de Paris", ore: 8, minuti: 20, categoria: .shopping,tappe:[])
    ]
    
    var body: some View {
        NavigationStack {
            if itinerari.isEmpty{
                Text("Nessun itinerario salvato!")
                    .font(.headline)
                    .padding()
            }
            List {
                ForEach($itinerari,id: \.id) { $itinerario in
                    NavigationLink(destination: ItinerarioView(itinerario:$itinerario)) {
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
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            togglePreferito(itinerario)
                            itinerari.sort{$0.preferito && !$1.preferito}
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
        .onAppear(){
            itinerari.sort{$0.preferito && !$1.preferito}
        }
    }
        
    
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
