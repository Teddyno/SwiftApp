// ScansioneUtils.swift
// Funzioni di utility per il parsing e l'estrazione di dati da stringhe di biglietti:
// - Estrazione di nome, cognome, partenza, destinazione da stringhe BCBP/IATA
// - Estrazione orario volo da stringhe con pattern numerici
// - Utili per la normalizzazione e la validazione dei dati scansionati


import Foundation

struct ItinerarioEstratto: Identifiable {
    let id = UUID()
    let raw: String
    let partenza: String?
    let destinazione: String?
    let passeggero: String?
    let compagnia: String?
    let info: [String: String]?

    static func parse(from text: String) -> ItinerarioEstratto {
        if let dati = estraiDatiDa(text) {
            var info: [String: String] = [:]
            if let orario = estraiOrarioVoloDa(text) {
                info["orario"] = orario
            }
            return ItinerarioEstratto(
                raw: text,
                partenza: dati.partenza,
                destinazione: dati.destinazione,
                passeggero: "\(dati.cognome) \(dati.nome)",
                compagnia: nil,
                info: info
            )
        }

        if text.starts(with: "M1") && text.count >= 60 {
            let p = { (start: Int, len: Int) in
                let s = text.index(text.startIndex, offsetBy: start)
                let e = text.index(s, offsetBy: len)
                return String(text[s..<e])
            }
            let passeggero = p(2, 20).trimmingCharacters(in: .whitespaces)
            let partenza = p(15, 3)
            let destinazione = p(18, 3)
            let compagnia = p(21, 3).trimmingCharacters(in: .whitespaces)
            let volo = p(24, 5).trimmingCharacters(in: .whitespaces)
            let giornoAnno = p(36, 3)
            let info: [String: String] = [
                "compagnia": compagnia,
                "volo": volo,
                "giornoAnno": giornoAnno
            ]
            return ItinerarioEstratto(
                raw: text,
                partenza: partenza,
                destinazione: destinazione,
                passeggero: passeggero.isEmpty ? nil : passeggero,
                compagnia: compagnia.isEmpty ? nil : compagnia,
                info: info
            )
        }

        if let data = text.data(using: .utf8),
           let dict = try? JSONSerialization.jsonObject(with: data) as? [String: String] {
            return ItinerarioEstratto(
                raw: text,
                partenza: dict["partenza"] ?? dict["from"],
                destinazione: dict["destinazione"] ?? dict["to"],
                passeggero: dict["passeggero"] ?? dict["name"],
                compagnia: dict["compagnia"] ?? dict["company"],
                info: dict
            )
        }

        func match(_ pattern: String) -> String? {
            guard let r = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
                  let m = r.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)),
                  let range = Range(m.range(at: 1), in: text) else { return nil }
            return String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
        }

        let partenza = match(#"from[":\s]+([A-Z]{3})"#) ?? match(#"partenza[":\s]+([A-Z]{3})"#)
        let destinazione = match(#"to[":\s]+([A-Z]{3})"#) ?? match(#"destinazione[":\s]+([A-Z]{3})"#)
        let passeggero = match(#"name[":\s]+([A-Za-z\s]+)"#) ?? match(#"passeggero[":\s]+([A-Za-z\s]+)"#)
        let compagnia = match(#"company[":\s]+([A-Za-z0-9\s]+)"#) ?? match(#"compagnia[":\s]+([A-Za-z0-9\s]+)"#)

        if partenza != nil || destinazione != nil || passeggero != nil {
            return ItinerarioEstratto(
                raw: text,
                partenza: partenza,
                destinazione: destinazione,
                passeggero: passeggero,
                compagnia: compagnia,
                info: nil
            )
        }

        return ItinerarioEstratto(raw: text, partenza: nil, destinazione: nil, passeggero: nil, compagnia: nil, info: nil)
    }
}

func estraiDatiDa(_ stringa: String) -> (cognome: String, nome: String, partenza: String, destinazione: String)? {
    guard let rangeM1 = stringa.range(of: "M1") else { return nil }
    let dopoM1 = stringa[rangeM1.upperBound...]
    guard let fineNome = dopoM1.firstIndex(of: " ") else { return nil }
    let nomeCognomeRaw = dopoM1[..<fineNome]
    let nomeParts = nomeCognomeRaw.split(separator: "/")
    guard nomeParts.count == 2 else { return nil }
    let cognome = String(nomeParts[0])
    let nome = String(nomeParts[1])
    let resto = dopoM1[fineNome...]
    let pattern = "[A-Z]{6}"
    let regex = try! NSRegularExpression(pattern: pattern)
    let matches = regex.matches(in: String(resto), range: NSRange(resto.startIndex..., in: resto))
    guard let match = matches.first else { return nil }
    let codice = (String(resto) as NSString).substring(with: match.range)
    let partenza = String(codice.prefix(3))
    let destinazione = String(codice.suffix(3))
    return (cognome, nome, partenza, destinazione)
}

func estraiOrarioVoloDa(_ testo: String) -> String? {
    let pattern = "\\b\\d{3,4}\\b"
    guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
    let nsrange = NSRange(testo.startIndex..., in: testo)
    let matches = regex.matches(in: testo, range: nsrange)

    let orariValidi = matches.compactMap { match -> (Int, String)? in
        let numero = (testo as NSString).substring(with: match.range)
        guard let intVal = Int(numero) else { return nil }
        let ore = intVal / 100
        let minuti = intVal % 100
        guard ore >= 0 && ore < 24 && minuti >= 0 && minuti < 60 else { return nil }
        let orario = String(format: "%02d:%02d", ore, minuti)
        return (match.range.location, orario)
    }

    let paroleChiave = ["EK", "LH", "AZ", "AF", "FR", "U2", "VY", "JU", "KL", "AA", "BA"]
    let posizioneRiferimento = paroleChiave.compactMap { keyword -> Int? in
        guard let r = testo.range(of: keyword) else { return nil }
        return testo.distance(from: testo.startIndex, to: r.lowerBound)
    }.min()

    if let posizioneRif = posizioneRiferimento {
        return orariValidi.min(by: { abs($0.0 - posizioneRif) < abs($1.0 - posizioneRif) })?.1
    }

    return orariValidi.first?.1
}

#if DEBUG
import SwiftUI
struct ItinerarioEstratto_Previews: PreviewProvider {
    static var previews: some View {
        let estratto = ItinerarioEstratto.parse(from: "M1TEDESCO/ALESSANDRO  EK7VDL98PRGNAPJU4274 355 3C  532  10A2585752900")
        VStack(alignment: .leading, spacing: 8) {
            Text("Passeggero: \(estratto.passeggero ?? "-")")
            Text("Partenza: \(estratto.partenza ?? "-")")
            Text("Destinazione: \(estratto.destinazione ?? "-")")
        }
        .padding()
    }
}
#endif
