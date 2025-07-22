// AnteprimaItinerarioView.swift
// View di supporto che mostra i dati estratti dal biglietto scansionato prima della conferma:
// - Visualizza il testo grezzo e i dati estratti (passeggero, compagnia, orario, volo, ecc.)
// - Permette la copia del testo grezzo negli appunti
// - Espone una callback di conferma per proseguire il flusso di scansione


import SwiftUI
import Foundation

struct AnteprimaItinerarioView: View {
    let dati: ItinerarioEstratto
    let conferma: () -> Void
    @State private var copied = false
    private static let aeroporti: [Aeroporto] = caricaAeroporti()
    private func nomeAeroporto(iata: String?) -> String {
        guard let iata = iata else { return "-" }
        return Self.aeroporti.first(where: { $0.iata.uppercased() == iata.uppercased() })?.displayName ?? iata
    }
    var body: some View {
        VStack(spacing: 20) {
            Text("Anteprima biglietto")
                .font(.title2)
                .fontWeight(.bold)
            Text("Testo grezzo scansionato:")
                .font(.caption)
                .foregroundColor(.gray)
            ScrollView(.horizontal) {
                Text(dati.raw)
                    .font(.footnote)
                    .foregroundColor(.blue)
                    .padding(4)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 80)
            Button(action: {
                UIPasteboard.general.string = dati.raw
                copied = true
            }) {
                HStack {
                    Image(systemName: copied ? "checkmark.circle.fill" : "doc.on.doc")
                    Text(copied ? "Copiato!" : "Copia testo grezzo")
                }
                .font(.footnote)
                .foregroundColor(.mint)
                .padding(.vertical, 6)
                .padding(.horizontal, 16)
                .background(Color(.systemGray5))
                .cornerRadius(12)
            }
            Divider()
            if let p = dati.passeggero {
                Text("Passeggero: \(p)")
            }
            if let c = dati.compagnia {
                Text("Compagnia: \(c)")
            }
            if let info = dati.info {
                if let orario = info["orario"], !orario.isEmpty {
                    Text("Orario: \(orario)")
                }
                if let volo = info["volo"], !volo.isEmpty {
                    Text("Volo: \(volo)")
                }
                if let giornoAnno = info["giornoAnno"], !giornoAnno.isEmpty {
                    Text("Giorno dell'anno: \(giornoAnno)")
                }
            }
            if let p = dati.partenza {
                Text("Partenza: \(nomeAeroporto(iata: p))")
            }
            if let d = dati.destinazione {
                Text("Destinazione: \(nomeAeroporto(iata: d))")
            }
            if let info = dati.info {
                ForEach(info.sorted(by: { $0.key < $1.key }), id: \.key) { k, v in
                    if k != "volo" && k != "giornoAnno" && k != "compagnia" {
                        Text("\(k.capitalized): \(v)")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
            }
            Button("Conferma", action: conferma)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .padding(.horizontal, 32)
                .background(Color.mint)
                .cornerRadius(16)
                .padding(.top, 16)
        }
        .padding()
        .onAppear {
            print("[DEBUG] Testo grezzo scansionato:\n\(dati.raw)")
        }
    }
}

#if DEBUG
struct AnteprimaItinerarioView_Previews: PreviewProvider {
    static var previews: some View {
        AnteprimaItinerarioView(
            dati: ItinerarioEstratto.parse(from: "M1TEDESCO/ALESSANDRO  EK7VDL98PRGNAPJU4274 355 3C  532  10A2585752900"),
            conferma: {}
        )
    }
}
#endif 