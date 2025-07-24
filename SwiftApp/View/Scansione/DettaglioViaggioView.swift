// DettaglioViaggioView.swift
// View che visualizza i dettagli di un viaggio scansionato:
// - Mostra una timeline verticale con partenza, scalo e destinazione (TimelineStepCard)
// - Visualizza dati aggiuntivi come orario, volo, compagnia
// - Mostra il nome del passeggero associato
// - Include una preview SwiftUI e componenti riutilizzabili per la timeline

import SwiftUI
import Foundation

struct DettaglioViaggioView: View {
    let viaggio: Viaggio
    @EnvironmentObject var rootState: RootState
    @Environment(\.presentationMode) var presentationMode
    private var estrattoPartenza: ItinerarioEstratto { ItinerarioEstratto.parse(from: viaggio.partenza) }
    private var estrattoDest: ItinerarioEstratto { ItinerarioEstratto.parse(from: viaggio.destinazione) }
    private var scalo: String { viaggio.scalo }
    private static let aeroporti: [Aeroporto] = caricaAeroporti()
    
    private func nomeAeroporto(iata: String?) -> String {
        guard let iata = iata else { return "-" }
        return Self.aeroporti.first(where: { $0.iata.uppercased() == iata.uppercased() })?.displayName ?? iata
    }
    private func cittaAeroporto(iata: String?) -> String? {
        guard let iata = iata else { return nil }
        return Self.aeroporti.first(where: { $0.iata.uppercased() == iata.uppercased() })?.city
    }
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        TimelineStepCard(
                            title: "Partenza",
                            code: nomeAeroporto(iata: estrattoPartenza.partenza),
                            icon: "airplane.departure",
                            color: .mint
                        )
                        TimelineConnector()
                        TimelineStepCard(
                            title: "Scalo",
                            code: (!scalo.isEmpty && scalo != "Scalo") ? nomeAeroporto(iata: scalo) : "-",
                            icon: "arrow.triangle.branch",
                            color: .orange
                        )
                        TimelineConnector()
                        TimelineStepCard(
                            title: "Destinazione",
                            code: nomeAeroporto(iata: estrattoDest.destinazione ?? estrattoPartenza.destinazione),
                            icon: "flag.checkered",
                            color: .blue
                        )
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
                    if let passeggero = estrattoPartenza.passeggero {
                        HStack(spacing: 8) {
                            Image(systemName: "person.fill")
                                .foregroundColor(.mint)
                            Text(passeggero)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.top, 32)
                    }
                    Button(action: {
                        if let citta = cittaAeroporto(iata: scalo) {
                            rootState.scaloPrecompilato = citta
                        } else {
                            rootState.scaloPrecompilato = scalo
                        }
                        rootState.selectedTab = 1
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        HStack(spacing: 12) {
                            Image(systemName: "airplane.departure")
                                .font(.system(size: 26, weight: .bold))
                            Text("Scopri cosa fare durante lo scalo")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 18)
                        .padding(.horizontal, 32)
                        .background(Color.mint)
                        .cornerRadius(28)
                        .shadow(color: .mint.opacity(0.25), radius: 12, x: 0, y: 6)
                        .scaleEffect(1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: rootState.selectedTab)
                    })
                    .disabled(false)
                    .padding(.top, 36)
                    Spacer()
                }
            }
            .navigationTitle("Dettaglio Viaggio")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct TimelineStepCard: View {
    let title: String
    let code: String
    let icon: String
    let color: Color
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(code)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(24)
        .padding(.vertical, 10)
    }
} 

struct TimelineConnector: View {
    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 3, height: 24)
            .padding(.leading, 28)
    }
}

#if DEBUG
struct DettaglioViaggioView_Previews: PreviewProvider {
    static var previews: some View {
        DettaglioViaggioView(viaggio: Viaggio(
            partenza: "M1TEDESCO/ALESSANDRO  EK7VDL98PRGNAPJU4274 355 3C  532  10A2585752900",
            destinazione: "M1TEDESCO/ALESSANDRO  EK7VDL98NAPOTPJU4274 355 3C  532  10A2585752900",
            scalo: "NAP",
            itinerario: "PRG → OTP"
        ))
    }
}

struct TimelineStepCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            TimelineStepCard(title: "Partenza", code: "PRG", icon: "airplane.departure", color: .mint)
            TimelineConnector()
            TimelineStepCard(title: "Scalo", code: "NAP", icon: "arrow.triangle.branch", color: .orange)
            TimelineConnector()
            TimelineStepCard(title: "Destinazione", code: "OTP", icon: "flag.checkered", color: .blue)
        }
        .padding()
        .background(Color.white)
    }
}
#endif 
