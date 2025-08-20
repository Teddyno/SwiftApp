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
    @State private var itinerari:[Itinerario] = []
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
                    Image("Logo")
                        .padding(0)
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
                        .padding(.top, 5)
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
                        let sogliaMinuti: Int = {
                            // prova a trovare l'aeroporto selezionato e usare il suo `min` (ore) dal JSON
                            if let match = aeroporti.first(where: { $0.displayName == rootState.scaloPrecompilato }) {
                                if let h = match.min { return h * 60 }
                            } else if let iata = iataDaInput(), let a = aeroporti.first(where: { $0.iata == iata }) {
                                if let h = a.min { return h * 60 }
                            } else if let citta = cittàDaInput(), let a = aeroporti.first(where: { normalizza($0.city) == normalizza(citta) }) {
                                if let h = a.min { return h * 60 }
                            }
                            return 300 // fallback
                        }()
                        if durataTotaleMinuti < sogliaMinuti {
                            alertMessage = "Con la durata inserita non è consigliato uscire dall'aeroporto."
                            showAlert = true //
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
                .padding(.top,0)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Fine") { isTextFieldFocused = false }
                    }
                }
                .navigationDestination(isPresented: $navigateToItinerario) {
                                if let itinerario = itinerarioGenerato {
                                    ItinerarioView(itinerario: Binding(
                                        get: { self.itinerarioGenerato ?? itinerario },
                                        set: { self.itinerarioGenerato = $0 }
                                    ))
                                    .onChange(of: itinerarioGenerato){
                                        loadItinerari()
                                        for i in 0...itinerari.count-1{
                                            if itinerari[i].id==itinerarioGenerato!.id{
                                                itinerari[i].progress=itinerarioGenerato!.progress
                                            }
                                        }
                                        saveItinerari()
                                    }
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

    private func normalizza(_ s: String) -> String {
        // Normalizza stringhe (rimuove accenti e maiuscole) per confronti 
        return s.folding(options: .diacriticInsensitive, locale: .current).lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func cittàDaInput() -> String? {
        // Ricava la città dall'input dell'utente: prima da confronto esatto su displayName, poi dal testo (prima della parentesi)
        if let match = aeroporti.first(where: { $0.displayName == rootState.scaloPrecompilato }) {
            return match.city
        }
        let testo = rootState.scaloPrecompilato
        if let idx = testo.firstIndex(of: "(") {
            let city = String(testo[..<idx]).trimmingCharacters(in: .whitespacesAndNewlines)
            return city.isEmpty ? nil : city
        }
        return testo.isEmpty ? nil : testo
    }

    private func iataDaInput() -> String? {
        // Ricava il codice IATA dall'input: prima da confronto esatto su displayName, poi dal testo (prima della parentesi)
        if let match = aeroporti.first(where: { $0.displayName == rootState.scaloPrecompilato }) {
            return match.iata
        }
        let testo = rootState.scaloPrecompilato
        if let open = testo.firstIndex(of: "("), let close = testo.firstIndex(of: ")"), open < close {
            let code = testo[testo.index(after: open)..<close]
            let value = String(code).trimmingCharacters(in: .whitespacesAndNewlines)
            return value.isEmpty ? nil : value
        }
        return nil
    }

    private func estraIataDaAeroportoString(_ s: String) -> String? {
        // estrae il contenuto tra parentesi tonde, es: "Roma–Fiumicino (FCO)" -> "FCO"
        if let open = s.firstIndex(of: "("), let close = s.firstIndex(of: ")"), open < close {
            let code = s[s.index(after: open)..<close]
            let value = String(code).trimmingCharacters(in: .whitespacesAndNewlines)
            return value.isEmpty ? nil : value
        }
        return nil
    }

    private func minutesOfDay(from date: Date) -> Int {
        // Converte una data nei minuti dall'inizio del giorno (HH*60+mm)
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
    }

    private func minutesOfDay(fromHHmm string: String) -> Int? {
        // Converte una stringa HH:mm in minuti dall'inizio del giorno
        guard let d = DateFormatter.orario.date(from: string) else { return nil }
        return minutesOfDay(from: d)
    }

    private func trovaItinerarioLocale() -> Itinerario? {
        // Cerca un itinerario nel file locale in base a città/IATA, orario (±60m), durata (−60..0m), e preferenza
        guard let url = Bundle.main.url(forResource: "itinerari", withExtension: "json") else { return nil }
        guard let data = try? Data(contentsOf: url),
              let lista = try? JSONDecoder().decode([Itinerario].self, from: data) else { return nil }
        
        let cityInput = cittàDaInput()
        let iataInput = iataDaInput()?.uppercased()
        let userMinutes = minutesOfDay(from: orarioArrivo)
        let userOre = durataScaloOre()
        let userMinuti = durataScaloMinuti()
        let userPref = (preferenzaSelezionata?.lowercased() ?? "nessuna").trimmingCharacters(in: .whitespacesAndNewlines)
        
        let trovato = lista.first { it in
            // match città o IATA
            let cityOk: Bool = {
                if let c = cityInput { return normalizza(it.citta) == normalizza(c) }
                return false
            }()
            let iataOk: Bool = {
                if let iataIn = iataInput, let iataIt = estraIataDaAeroportoString(it.aeroporto)?.uppercased() {
                    return iataIn == iataIt
                }
                return false
            }()
            let luogoOk = cityOk || iataOk
            
            // match orario arrivo con tolleranza ±60 minuti
            let orarioOk: Bool = {
                guard let s = it.orarioArrivoScalo, let itMinutes = minutesOfDay(fromHHmm: s) else { return false }
                return abs(itMinutes - userMinutes) <= 60
            }()
            
            // match durata: accetta da durata utente - 60 minuti fino alla durata utente (mai superiore)
            let durataOk: Bool = {
                let localTotal = it.ore * 60 + it.minuti
                let userTotal = userOre * 60 + userMinuti
                return localTotal <= userTotal && localTotal >= userTotal - 60
            }()
            
            // match preferenza
            let prefOk: Bool = {
                if userPref == "nessuna" {
                    return it.categoria == nil
                }
                return it.categoria?.rawValue == userPref
            }()
            
            return luogoOk && orarioOk && durataOk && prefOk
        }
        return trovato
    }

    func promptItinerario() {
        if let locale = trovaItinerarioLocale() {
            self.itinerarioGenerato = locale
            saveItinerarioCreato(locale)
            self.navigateToItinerario = true
            return
        }
        
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
              \"aeroporto\": \"Nome dell'aeroporto (codice IATA)\",
              \"orarioArrivo\": \(orarioArrivoString)
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
          - almeno 1 ore e mezza prima del volo successivo per rientrare in aeroporto e superare i controlli
          - tempi medi di trasporto A/R tra aeroporto e città (es. treno, taxi, navetta)
          - se il tempo è sufficiente solo per 1 o 2 tappe, inserire 2 tappe di contorno vicino all'unica possibile
        - aggiungi una tappa iniziale con le indicazioni per uscire dall'aeroporto e arrivare in città
        - aggiungi una tappa finale con orario di partenza per tornare in aeroporto
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
            "model": "openai/gpt-oss-20b",
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
    private func findItinerarioIndex(for id: UUID) -> Int? {
        itinerari.firstIndex { $0.id == id }
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
