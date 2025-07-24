import SwiftUI

struct ListaItinerariView: View {
    @State private var itinerari: [Itinerario] = []
    @State private var searchText: String = ""
    
    var itinerariFiltrati: [Itinerario] {
        if searchText.isEmpty {
            return itinerari
        } else {
            return itinerari.filter { $0.citta.localizedCaseInsensitiveContains(searchText) || $0.aeroporto.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.mint)
                        .font(.system(size: 20))
                    TextField("Ricerca itinerario...", text: $searchText)
                        .padding()
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.white, .mint.opacity(0.15)]), startPoint: .trailing, endPoint: .leading))
                        .cornerRadius(15)
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 10)
                if itinerariFiltrati.isEmpty {
                    Text(searchText.isEmpty ? "Nessun itinerario salvato!" : "Nessun itinerario trovato!")
                        .font(.headline)
                        .padding(50)
                }
                List {
                    ForEach(itinerariFiltrati, id: \.id) { itinerario in
                        NavigationLink(destination: ItinerarioView(itinerario: .constant(itinerario))) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(itinerario.testo().uppercased())
                                    Text("\(itinerario.categoria.rawValue.capitalized)")
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
                                togglePreferito(for: itinerario)
                            } label: {
                                if itinerario.preferito {
                                    Label("Rimuovi dai preferiti", systemImage: "star.slash.fill")
                                } else {
                                    Label("Aggiungi ai preferiti", systemImage: "star")
                                }
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
                .listStyle(.plain)
            }
            .navigationTitle("Itinerari")
            .navigationBarTitleDisplayMode(.large)
            .onAppear(perform: loadItinerari)
        }
    }
    
    private func getItinerariFileURL() -> URL? {
        let fileManager = FileManager.default
        guard let docURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return docURL.appendingPathComponent("itinerariCreati.json")
    }

    private func ensureItinerariFileExists() {
        guard let fileURL = getItinerariFileURL() else { return }
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            if let bundleURL = Bundle.main.url(forResource: "itinerariCreati", withExtension: "json") {
                do {
                    try FileManager.default.copyItem(at: bundleURL, to: fileURL)
                } catch {
                    print("Errore nella copia iniziale di itinerariCreati.json: \(error)")
                }
            }
        }
    }

    private func loadItinerari() {
        ensureItinerariFileExists()
        guard let fileURL = getItinerariFileURL(),
              let data = try? Data(contentsOf: fileURL),
              let decodedItinerari = try? JSONDecoder().decode([Itinerario].self, from: data) else {
            return
        }
        self.itinerari = decodedItinerari
        self.itinerari.sort { $0.preferito && !$1.preferito }
    }
    
    private func saveItinerari() {
        guard let fileURL = getItinerariFileURL() else { return }
        do {
            let encodedData = try JSONEncoder().encode(itinerari)
            try encodedData.write(to: fileURL, options: .atomic)
        } catch {
            print("Errore nel salvataggio degli itinerari: \(error)")
        }
    }
    
    private func togglePreferito(for itinerario: Itinerario) {
        if let index = itinerari.firstIndex(of: itinerario) {
            itinerari[index].preferito.toggle()
            itinerari.sort { $0.preferito && !$1.preferito }
            saveItinerari()
        }
    }
    
    private func eliminaItinerario(_ item: Itinerario) {
        if let index = itinerari.firstIndex(of: item) {
            itinerari.remove(at: index)
            saveItinerari()
        }
    }
}

#Preview {
    ListaItinerariView()
}
