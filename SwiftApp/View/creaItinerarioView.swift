//
//  creaItinerarioView.swift
//  SwiftApp
//
//  Created by Studente on 04/07/25.
//

import SwiftUI

struct creaItinerarioView: View {
    @EnvironmentObject var rootState: RootState
    @State var durataScalo: Date  = Calendar.current.date(
        bySettingHour: 0,
        minute: 0,
        second: 0,
        of: Date()
    )!
    @State var orarioArrivo: Date = Calendar.current.date(
        bySettingHour: 8, // default 08:00
        minute: 0,
        second: 0,
        of: Date()
    )!
    @State var preferenzaSelezionata: String? = nil
    @State var aeroporti: [Aeroporto] = []
    @State var risultatiFiltrati: [Aeroporto] = []
    @State var isLoading: Bool = false
    @State var itinerarioGenerato: Itinerario? = nil
    @State private var navigateToItinerario = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showOrarioPicker = false
    @FocusState private var isTextFieldFocused: Bool
    let preferenze = ["Natura", "Cibo", "Monumenti", "Shopping"]

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Image("sfondo")
                        .resizable()
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 50))
                        .frame(maxWidth: .infinity, maxHeight: 620)
                        .ignoresSafeArea()
                    Spacer()
                }
                
                VStack() {
                    // Campo ricerca aeroporto
                    VStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.mint)
                            TextField("città/aeroporto", text: $rootState.scaloPrecompilato)
                                .focused($isTextFieldFocused)
                                .onChange(of: rootState.scaloPrecompilato) { oldValue, newValue in
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
                                .foregroundColor(.black)
                                .frame(minHeight: 27)  // altezza minima tappabile
                        }
                        .padding(20)  // padding sull'intero HStack per area tappabile più grande
                        .contentShape(Rectangle())  // estende l'area tappabile a tutto il rettangolo
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: .mint.opacity(0.08), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 30)
                        .frame(maxWidth: 500)
                        .padding(.top, 25)
                    }

                    
                    // Orario di arrivo
                    HStack(spacing: 8){
                        Image(systemName: "clock")
                            .foregroundColor(.mint)
                            .font(.system(size: 20, weight: .semibold))
                            .padding(.horizontal,20)
                            .padding(.vertical, 20)
                        Spacer()
                        Text("Orario di arrivo")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.leading, 15)
                            .padding(.top,5)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                        Spacer()
                        DatePicker("", selection: $orarioArrivo, displayedComponents: [.hourAndMinute])
                            .labelsHidden()
                            .colorMultiply(.black)
                            .padding(.horizontal,20)
                    }
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .mint.opacity(0.08), radius: 8, x: 0, y: 2)
                    .padding(.horizontal, 30)
                    .frame(maxWidth: 500)
                    .padding(.vertical, 3)
                    .padding(.top, 25)
                    
                    // Durata scalo
                    HStack(spacing: 8){
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(.mint)
                            .font(.system(size: 20, weight: .semibold))
                            .padding(.horizontal,20)
                            .padding(.vertical, 20)
                        Spacer()
                        Text("Durata scalo")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.leading, 15)
                            .padding(.top,5)
                        Spacer()
                        DatePicker("", selection: $durataScalo, displayedComponents: [.hourAndMinute])
                            .labelsHidden()
                            .colorMultiply(.black)
                            .padding(.horizontal,20)
                    }
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .mint.opacity(0.08), radius: 8, x: 0, y: 2)
                    .padding(.horizontal, 30)
                    .frame(maxWidth: 500)
                    .padding(.vertical, 3)
                    
                    // Preferenze/interessi
                    VStack {
                        Text("Scegli uno tra questi interessi")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.top,10)
                        LazyVGrid(columns: [GridItem(spacing: 15), GridItem()], spacing: 15) {
                            ForEach(preferenze, id: \.self) { interest in
                                Button(action: {
                                    preferenzaSelezionata = interest.lowercased()
                                }) {
                                    Text(interest)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 15)
                                        .background(preferenzaSelezionata == interest.lowercased() ? Color.mint : Color.gray.opacity(0.2))
                                        .foregroundColor(.black)
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom,10)
                    }
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .mint.opacity(0.08), radius: 8, x: 0, y: 2)
                    .padding(.horizontal, 30)
                    .frame(maxWidth: 500)
                    .padding(.top, 30)
                    
                    Spacer(minLength: 0)
                    
                    // Bottone genera itinerario
                    Button(action: {
                        let durataTotaleMinuti = durataScaloOre() * 60 + durataScaloMinuti()
                        if durataTotaleMinuti == 0 {
                            alertMessage = "Inserisci la durata dello scalo."
                            showAlert = true
                            return
                        }
                        if durataTotaleMinuti < 90 {
                            alertMessage = "Con la durata inserita non è consigliato uscire dall'aeroporto."
                            showAlert = true
                            return
                        }
                        promptItinerario()
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
                        .shadow(color: .gray.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .disabled(isLoading)
                    .padding(.horizontal, 30)
                    .padding(.top, 30)
                    .padding(.bottom, 50)
                    .frame(maxWidth: 500)
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Attenzione"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
                }
                .padding(.top,60)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Fine") { isTextFieldFocused = false }
                    }
                }
                .navigationDestination(isPresented: $navigateToItinerario) {
                    if let itinerario = itinerarioGenerato {
                        ItinerarioView(itinerario: .constant(itinerario))
                    }
                }
                
                //suggerimenti aeroporti
                VStack {
                    if !risultatiFiltrati.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(risultatiFiltrati) { aeroporto in
                                Button(action: {
                                    rootState.scaloPrecompilato = aeroporto.displayName
                                    risultatiFiltrati = []
                                    isTextFieldFocused = false
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
                        .frame(maxWidth: 500)
                        .padding(.top, 160) // Posiziona sotto al TextField
                    } else {
                        Spacer()
                    }
                    Spacer()
                }
                .zIndex(1) // Assicura che sia sopra gli altri elementi
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .onAppear {
                aeroporti = caricaAeroporti()
            }
        }
    }
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    func promptItinerario() {
        /*
        guard let chiaveAPI = ProcessInfo.processInfo.environment["GROQ_API_KEY"] else {
                    print("❌ Variabile di ambiente GROQ_API_KEY non trovata.")
                    return
                }*/
        
        guard let chiaveAPI = Bundle.main.object(forInfoDictionaryKey: "GROG_API_KEY") as? String else {
                    fatalError("❌ Variabile di ambiente GROQ_API_KEY non trovata.")
                }
        let preferenza = preferenzaSelezionata ?? "nessuna preferenza"
        let aeroporto = rootState.scaloPrecompilato.isEmpty ? "[inserisci aeroporto]" : rootState.scaloPrecompilato
        let ore = durataScaloOre()
        let minuti = durataScaloMinuti()
        let orarioArrivoString = DateFormatter.orario.string(from: orarioArrivo)
        let prompt = """
        Genera un itinerario di viaggio per un passeggero in scalo presso l'aeroporto \(aeroporto), con arrivo previsto alle ore \(orarioArrivoString), durata di scalo pari a \(ore) ore e \(minuti) minuti, e preferenza di attività \(preferenza).
        Requisiti:
        - L'output deve essere **esclusivamente un JSON**, strutturato esattamente come il seguente esempio:
          [
            {
              \"citta\": \"Nome della città\",
              \"aeroporto\": \"Nome dell'aeroporto\",
              \"ore\": numero intero (ore di scalo),
              \"minuti\": numero intero (minuti di scalo),
              \"categoria\": categoria preferita (es. \"monumenti\", \"cibo\", \"natura\"),
              \"preferito\": false,
              \"tappe\": [
                {
                  \"nome\": \"Nome della tappa\",
                  \"descr\": \"Breve descrizione della tappa\",
                  \"oraArrivo\": \"HH:mm\",
                  \"foto\": \"url a una foto online, reperibile e visualizzabile della tappa, in formato .jpg o .png\",
                  \"maps\": \"URL apple Maps\"
                  \"latitudine\": valore decimale (es. 41.4036),
                  \"longitudine\": valore decimale (es. 2.1744)
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
        - Inserisci al massimo 7 tappe coerenti con la durata utile
        - Le tappe devono riflettere la categoria preferita inserita da \(preferenza)
        - Inserisci solo tappe realisticamente raggiungibili e visitabili nel tempo utile
        - Ogni tappa deve includere: nome in lingua originale, descrizione, orario di arrivo stimato, l'URL assoluto della prima immagine che appare su Google Immagini, link Apple Maps, latitudine e longitudine corretti
        -Le immagini devono risultare url che restituiscono una foto visualizzabile, devono essere immagini commons di wikipedia con link https://commons.wikimedia.org/wiki/Special:FilePath/..., prova a cercare il nome completo della tappa e tra parentesi il nome della città
        Restituisci solo il JSON come testo puro, **senza usare markdown, senza backtick**, né altri caratteri extra.
    """;
        //print("\(prompt)");
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
                    print("⚠️ Errore nella risposta API")                }
                return
            }
            print("JSON ricevuto:\n\(content)")
            DispatchQueue.main.async {
                // Prova a parsare il JSON per creare l'oggetto Itinerario
                parseItinerarioFromJSON(content.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }.resume()
    }
    func parseItinerarioFromJSON(_ jsonString: String) {
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Errore nella conversione della stringa JSON")
            return
        }
        do {
            let itinerari = try JSONDecoder().decode([Itinerario].self, from: jsonData)
            if let primoItinerario = itinerari.first {
                self.itinerarioGenerato = primoItinerario
                saveItinerarioCreato(primoItinerario)
                self.navigateToItinerario = true
                print("Itinerario creato con successo per: \(primoItinerario.citta)")
            }
        } catch {
            print("Errore nel parsing JSON: \(error)")
            let cleanedJSON = cleanJSONString(jsonString)
            print("JSON ricevuto pulito :\n\(cleanedJSON)")
            if let cleanedData = cleanedJSON.data(using: .utf8) {
                do {
                    let itinerari = try JSONDecoder().decode([Itinerario].self, from: cleanedData)
                    if let primoItinerario = itinerari.first {
                        self.itinerarioGenerato = primoItinerario
                        saveItinerarioCreato(primoItinerario)
                        self.navigateToItinerario = true
                        print("Itinerario creato con successo (dopo pulizia JSON) per: \(primoItinerario.citta)")
                    }
                } catch {
                    print("Errore nel parsing JSON anche dopo pulizia: \(error)")
                }
            }
        }
    }
    func cleanJSONString(_ jsonString: String) -> String {
        var cleaned = jsonString
        cleaned = cleaned.replacingOccurrences(of: "```json", with: "")
        cleaned = cleaned.replacingOccurrences(of: "```", with: "")
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        if let startIndex = cleaned.firstIndex(of: "["),
           let endIndex = cleaned.lastIndex(of: "]") {
            cleaned = String(cleaned[startIndex...endIndex])
        }
        return cleaned
    }
    func saveItinerarioCreato(_ nuovo: Itinerario) {
        let fileManager = FileManager.default
        let filename = "itinerariCreati.json"
        guard let docURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("❌ Impossibile trovare la document directory")
            return
        }
        let fileURL = docURL.appendingPathComponent(filename)
        var itinerari: [Itinerario] = []
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                itinerari = try JSONDecoder().decode([Itinerario].self, from: data)
            } catch {
                print("⚠️ Errore durante la lettura del file esistente: \(error)")
            }
        }
        itinerari.append(nuovo)
        do {
            let encoded = try JSONEncoder().encode(itinerari)
            try encoded.write(to: fileURL, options: [.atomic, .completeFileProtection])
            print("✅ Itinerario salvato in \(fileURL)")
        } catch {
            print("❌ Errore nel salvataggio di \(filename): \(error)")
        }
    }
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

extension DateFormatter {
    static let orario: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return df
    }()
}

#Preview {
    creaItinerarioView()
}
