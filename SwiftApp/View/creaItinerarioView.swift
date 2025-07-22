//
//  creaItinerarioView.swift
//  SwiftApp
//
//  Created by Studente on 04/07/25.
//

import SwiftUI

struct creaItinerarioView: View {
    
    @State var luogoScalo: String = ""
    @State var durataScalo: Date  = Calendar.current.date(
        bySettingHour: 0,
        minute: 0,
        second: 0,
        of: Date()
    )!
    @State var preferenzaSelezionata: String? = nil
    
    @State var aeroporti: [Aeroporto] = []
    @State var risultatiFiltrati: [Aeroporto] = []
    
    @State var isLoading: Bool = false
    @State var itinerarioGenerato: Itinerario? = nil
    
    let preferenze = ["Natura", "Cibo", "Monumenti", "Shopping"]
    
    var body: some View {
        ZStack {
            VStack {
                Image("sfondo")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 50))
                    .ignoresSafeArea()
                Spacer()
            }
            
            VStack {
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.mint)
                        TextField("città/aeroporto", text: $luogoScalo)
                            .onChange(of: luogoScalo) { oldValue, newValue in
                                if newValue.isEmpty {
                                    risultatiFiltrati = []
                                } else {
                                    risultatiFiltrati = aeroporti.filter {
                                        $0.city.localizedCaseInsensitiveContains(newValue) ||
                                        $0.name.localizedCaseInsensitiveContains(newValue) ||
                                        $0.iata.localizedCaseInsensitiveContains(newValue)
                                    }.prefix(5).map { $0 }
                                }
                            }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 35)
                .padding(.top, 10)
                
                // Durata scalo
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.mint)
                    Text("Durata scalo")
                        .font(.headline)
                        .padding(.leading)
                        .foregroundColor(.gray)
                    DatePicker("", selection: $durataScalo, displayedComponents: [.hourAndMinute])
                        .colorMultiply(.black)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .padding(.horizontal, 35)
                .padding(.top, 10)
                
                // Preferenze
                VStack {
                    Text("Scegli uno tra questi interessi")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    LazyVGrid(columns: [GridItem(spacing: 15), GridItem()],
                              spacing: 15) {
                        ForEach(preferenze, id: \.self) { interest in
                            Button(action: {
                                preferenzaSelezionata = interest.lowercased()
                            }) {
                                Text(interest)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .padding(.top, 15)
                                    .padding(.bottom, 15)
                                    .background(preferenzaSelezionata == interest.lowercased() ? Color.mint : Color.gray.opacity(0.2))
                                    .foregroundColor(preferenzaSelezionata == interest.lowercased() ? .white : .gray)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(30)
                .padding(.horizontal, 35)
                .padding(.top, 40)
                
                Spacer()
                
                Button(action: {
                    promptItinerario() // Azione per generare itinerario
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        Text(isLoading ? "Generando..." : "Genera itinerario")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isLoading ? Color.gray : Color.mint)
                    .cornerRadius(20)
                    .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 4)
                }
                .disabled(isLoading)
                .padding(.horizontal, 35)
                .padding(.bottom, 50)
            }
            .padding(.top, 90)
            
            // Lista suggerimenti posizionata in modo assoluto
            VStack {
                if !risultatiFiltrati.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(risultatiFiltrati) { aeroporto in
                            Button(action: {
                                luogoScalo = aeroporto.displayName
                                risultatiFiltrati = []
                                hideKeyboard()
                            }) {
                                Text(aeroporto.displayName)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white)
                                    .foregroundColor(.black)
                            }
                            if aeroporto.id != risultatiFiltrati.last?.id {
                                Divider()
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                    .padding(.horizontal, 35)
                    .padding(.top, 170) // Posiziona sotto al TextField
                } else {
                    Spacer()
                }
                Spacer()
            }
            .zIndex(1) // Assicura che sia sopra gli altri elementi
        }
        .background(Color.white)
        .onAppear {
            aeroporti = caricaAeroporti()
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func promptItinerario() {
        
        guard let chiaveAPI = Bundle.main.infoDictionary?["GROQ_API_KEY"] as? String else {
                print("❌ Chiave API non trovata.")
                return
        }
        
        let preferenza = preferenzaSelezionata ?? "nessuna preferenza"
        let aeroporto = luogoScalo.isEmpty ? "[inserisci aeroporto]" : luogoScalo
        let ore = durataScaloOre()
        let minuti = durataScaloMinuti()

        let prompt = """
        Genera un itinerario di viaggio per un passeggero in scalo presso l'aeroporto \(aeroporto), con durata di scalo pari a \(ore) ore e \(minuti) minuti, e preferenza di attività \(preferenza).

        Requisiti:
        - L'output deve essere **esclusivamente un JSON**, strutturato esattamente come il seguente esempio:
          [
            {
              \"citta\": \"Nome della città\",
              \"aeroporto\": \"Nome dell'aeroporto\",
              \"ore\": numero intero (ore di scalo),
              \"minuti\": numero intero (minuti di scalo),
              \"categoria\": categoria preferita (es. \"monumenti\", \"cibo\", \"natura\"),
              \"preferito\": true/false,
              \"tappe\": [
                {
                  \"nome\": \"Nome della tappa\",
                  \"descr\": \"Breve descrizione della tappa\",
                  \"oraArrivo\": \"HH:mm\",
                  \"foto\": \"nome_immagine.jpg\",
                  \"maps\": \"URL apple Maps\"
                },
                ...
              ]
            }
          ]

        Regole aggiuntive:
        - Calcola in automatico il tempo utile per l'itinerario, togliendo:
          - almeno 1 ora all'arrivo per immigrazione e dogana
          - almeno 2 ore prima del volo successivo per rientrare in aeroporto e superare i controlli
          - tempi medi di trasporto A/R tra aeroporto e città, se rilevanti (es. treno, taxi, navetta)
        - Inserisci al massimo 5 tappe coerenti con la durata utile
        - Le tappe devono riflettere la categoria preferita inserita da \(preferenza)
        - Inserisci solo tappe realisticamente raggiungibili e visitabili nel tempo utile
        - `preferito` sarà `true` se la categoria corrisponde ad attività culturali o paesaggistiche
        - Ogni tappa deve includere: nome, descrizione, orario di arrivo stimato, nome del file immagine (fittizio o generico), e link Apple Maps

        Restituisci solo il JSON come testo puro, **senza usare markdown, senza backtick**, né altri caratteri extra.
    """;
        print("\(prompt)");
        
        let messagePayload = [["role": "user", "content": prompt]]

        guard let url = URL(string: "https://api.groq.com/openai/v1/chat/completions") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(chiaveAPI)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "meta-llama/llama-4-scout-17b-16e-instruct",
            "messages": messagePayload,
            "temperature": 0.7
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else { return }
        request.httpBody = httpBody

        isLoading = true
        URLSession.shared.dataTask(with: request) { data, _, error in
            defer {
                DispatchQueue.main.async {
                    isLoading = false
                }
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                DispatchQueue.main.async {
                    print("⚠️ Errore nella risposta API")
                }
                return
            }

            print("JSON ricevuto:\n\(content)")

            DispatchQueue.main.async {
                // Prova a parsare il JSON per creare l'oggetto Itinerario
                parseItinerarioFromJSON(content.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            

        }.resume()
    }

    // Funzione per parsare il JSON e creare l'oggetto Itinerario
    func parseItinerarioFromJSON(_ jsonString: String) {
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Errore nella conversione della stringa JSON")
            return
        }
        
        do {
            let itinerari = try JSONDecoder().decode([Itinerario].self, from: jsonData)
            if let primoItinerario = itinerari.first {
                // Salva l'itinerario nella variabile
                self.itinerarioGenerato = primoItinerario
                saveItinerarioCreato(primoItinerario)
                print("Itinerario creato con successo per: \(primoItinerario.citta)")
            }
        } catch {
            print("Errore nel parsing JSON: \(error)")
            // Prova a pulire il JSON se contiene caratteri extra
            let cleanedJSON = cleanJSONString(jsonString)
            print("JSON ricevuto pulito :\n\(cleanedJSON)")
            if let cleanedData = cleanedJSON.data(using: .utf8) {
                do {
                    let itinerari = try JSONDecoder().decode([Itinerario].self, from: cleanedData)
                    if let primoItinerario = itinerari.first {
                        self.itinerarioGenerato = primoItinerario
                        saveItinerarioCreato(primoItinerario)
                        print("Itinerario creato con successo (dopo pulizia JSON) per: \(primoItinerario.citta)")
                    }
                } catch {
                    print("Errore nel parsing JSON anche dopo pulizia: \(error)")
                }
            }
        }
        
        
    }

    // Funzione per pulire la stringa JSON da eventuali caratteri extra
    func cleanJSONString(_ jsonString: String) -> String {
        var cleaned = jsonString
        
        // Rimuovi eventuali ``` o ```json all'inizio e alla fine
        cleaned = cleaned.replacingOccurrences(of: "```json", with: "")
        cleaned = cleaned.replacingOccurrences(of: "```", with: "")
        
        // Rimuovi spazi e newline all'inizio e alla fine
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Trova l'inizio e la fine del JSON array
        if let startIndex = cleaned.firstIndex(of: "["),
           let endIndex = cleaned.lastIndex(of: "]") {
            cleaned = String(cleaned[startIndex...endIndex])
        }
        
        return cleaned
    }
    
    // Salva l'itinerario generato in itinerariCreati.json
    func saveItinerarioCreato(_ nuovo: Itinerario) {
        let fileManager = FileManager.default
        let filename = "itinerariCreati.json"
        guard let docURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Impossibile trovare la document directory")
            return
        }
        let fileURL = docURL.appendingPathComponent(filename)
        var itinerari: [Itinerario] = []
        // Prova a leggere quelli già presenti
        if let data = try? Data(contentsOf: fileURL) {
            if let decoded = try? JSONDecoder().decode([Itinerario].self, from: data) {
                itinerari = decoded
            }
        } else if let bundleURL = Bundle.main.url(forResource: "itinerariCreati", withExtension: "json"),
                  let bundleData = try? Data(contentsOf: bundleURL),
                  let decoded = try? JSONDecoder().decode([Itinerario].self, from: bundleData) {
            itinerari = decoded
        }
        itinerari.append(nuovo)
        do {
            let encoded = try JSONEncoder().encode(itinerari)
            try encoded.write(to: fileURL, options: .atomic)
            print("Itinerario salvato in \(fileURL)")
        } catch {
            print("Errore nel salvataggio di itinerariCreati.json: \(error)")
        }
    }
    
    // Helpers per calcolare ore e minuti da durataScalo
    private func durataScaloOre() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: calendar.startOfDay(for: Date()), to: durataScalo)
        return components.hour ?? 0
    }
    
    private func durataScaloMinuti() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: calendar.startOfDay(for: Date()), to: durataScalo)
        return components.minute ?? 0
    }
}

#Preview {
    creaItinerarioView()
}
