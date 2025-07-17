import SwiftUI

enum Categoria: String, Codable {
    case cibo, monumenti, natura, shopping
}

struct ListaItinerariView: View {
    @Binding var itinerari: [Itinerario]
    
    var body: some View {
        NavigationStack {
            VStack{
                if itinerari.isEmpty{
                    Text("Nessun itinerario salvato!")
                        .font(.headline)
                        .padding(50)
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
                        .swipeActions(edge: .trailing) {
                            Button {
                                togglePreferito(itinerario)
                            } label: {
                                Label("Preferiti", systemImage: itinerario.preferito ? "star.fill" : "star")
                            }
                            .tint(.mint)
                            Button(role: .destructive) {
                                eliminaItinerario(itinerario)
                            } label: {
                                Label("Elimina", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Itinerari")
            .navigationBarTitleDisplayMode(.large)
            
            .toolbar{
                ToolbarItem(placement: .topBarTrailing){
                    Button(action:{}){
                        Image(systemName:"magnifyingglass")
                            .foregroundColor(.mint)
                    }
                    .padding(30)
                    .padding(.top, 90)
                }
            }
        }
    }
    
    func togglePreferito(_ item: Itinerario) {
        if let index = itinerari.firstIndex(of: item) {
            itinerari[index].preferito.toggle()
            itinerari.sort { $0.preferito && !$1.preferito }
        }
    }
    
    func eliminaItinerario(_ item: Itinerario) {
        if let index = itinerari.firstIndex(of: item) {
            itinerari.remove(at: index)
        }
    }
}

#Preview {
    ListaItinerariView(itinerari: .constant([Itinerario(citta: "Barcellona", aeroporto: "", ore: 6, minuti: 20, categoria: .monumenti, tappe: []), Itinerario(citta: "Napoli", aeroporto: "", ore: 6, minuti: 20, categoria: .monumenti, tappe: []), Itinerario(citta: "Parigi", aeroporto: "", ore: 6, minuti: 20, categoria: .monumenti, tappe: []),]))
}
