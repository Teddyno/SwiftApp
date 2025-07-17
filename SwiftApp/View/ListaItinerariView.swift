import SwiftUI

enum Categoria: String, Codable {
    case cibo, monumenti, natura, shopping
}

struct ListaItinerariView: View {
    @Binding var itinerari: [Itinerario]
    @State var filtrati:[Itinerario]=[]
    @State var search=false
    @State var text=""
    
    var body: some View {
        NavigationStack {
            VStack{
                HStack{
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.mint)
                        .font(.system(size: 20))
                    TextField("Ricerca itinerario...",text:$text)
                        .onChange(of: text){
                            if text.isEmpty{
                                filtrati=itinerari
                            }else{
                                filtrati=itinerari.filter{$0.citta.localizedCaseInsensitiveContains(text)}
                            }
                        }
                }
                .padding(30)
                if itinerari.isEmpty{
                    Text("Nessun itinerario salvato!")
                        .font(.headline)
                        .padding(50)
                }else if filtrati.isEmpty{
                    Text("Nessun itinerario trovato!")
                        .font(.headline)
                        .padding(50)
                }
                List {
                    ForEach($filtrati,id: \.id) { $itinerario in
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
                                togglePreferito(itinerario);filtrati=itinerari
                            } label: {
                                Label("Preferiti", systemImage: itinerario.preferito ? "star.fill" : "star")
                            }
                            .tint(.mint)
                            Button(role: .destructive) {
                                eliminaItinerario(itinerario);filtrati=itinerari
                            } label: {
                                Label("Elimina", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Itinerari")
            .navigationBarTitleDisplayMode(.large)
            
        }
        .onAppear(){
            filtrati=itinerari
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
