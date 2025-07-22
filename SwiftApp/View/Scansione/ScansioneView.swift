// ScansioneView.swift
import SwiftUI
import AVFoundation
import PhotosUI
import Vision

struct ScansioneView: View {
    @State private var viaggi: [Viaggio] = []
    @State private var primoBiglietto: String? = nil
    @State private var mostraScannerPrimo = false
    @State private var mostraScannerSecondo = false
    @State private var mostraActionSheetPrimo = false
    @State private var mostraActionSheetSecondo = false
    @State private var mostraImagePicker = false
    @State private var imagePickerForPrimo = false
    @State private var selectedImage: UIImage? = nil
    @State private var anteprimaDati: ItinerarioEstratto? = nil
    @State private var anteprimaIndex: Int? = nil
    @State private var pendingSecondoBiglietto: String? = nil
    @State private var viaggioDaMostrare: Viaggio? = nil

    let viaggiEsempio: [Viaggio] = [
        Viaggio(
            partenza: "M1ROSSI/MARIO  AZ123FCONAPJU4274 355 3C  532  10A2585752900",
            destinazione: "M1ROSSI/MARIO  AZ123NAPOTPJU4274 355 3C  532  10A2585752900",
            scalo: "NAP",
            itinerario: "FCO → OTP"
        ),
        Viaggio(
            partenza: "M1BIANCHI/LUCA  LH456MXPFRAJU4274 355 3C  532  10A2585752900",
            destinazione: "M1BIANCHI/LUCA  LH456FRABCNJU4274 355 3C  532  10A2585752900",
            scalo: "FRA",
            itinerario: "MXP → BCN"
        )
    ]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 32) {
                    bigliettoButton(isPrimo: true)
                    bigliettoButton(isPrimo: false)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)

                Spacer().frame(height: 16)

                Text("Viaggi scansionati in precedenza")
                    .font(.title3)
                    .fontWeight(.medium)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                List {
                    ForEach(viaggi) { viaggio in
                        Button(action: { viaggioDaMostrare = viaggio }) {
                            makeViaggioRow(for: viaggio)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                if let idx = viaggi.firstIndex(where: { $0.id == viaggio.id }) {
                                    viaggi.remove(at: idx)
                                }
                            } label: {
                                Label("Elimina", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            }
            .navigationTitle("Scansione")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            if viaggi.isEmpty {
                viaggi = viaggiEsempio
            }
        }
        .confirmationDialog("Scegli sorgente", isPresented: $mostraActionSheetPrimo) {
            Button("Fotocamera") { mostraScannerPrimo = true }
            Button("File") {
                imagePickerForPrimo = true
                mostraImagePicker = true
            }
            Button("Annulla", role: .cancel) {}
        }
        .confirmationDialog("Scegli sorgente", isPresented: $mostraActionSheetSecondo) {
            Button("Fotocamera") { mostraScannerSecondo = true }
            Button("File") {
                imagePickerForPrimo = false
                mostraImagePicker = true
            }
            Button("Annulla", role: .cancel) {}
        }
        .sheet(isPresented: $mostraImagePicker, onDismiss: {
            if let image = selectedImage {
                riconosciCodiceDaImmagine(image: image, isPrimo: imagePickerForPrimo)
                selectedImage = nil
            }
        }) {
            ImagePicker(image: $selectedImage)
        }
        .sheet(isPresented: $mostraScannerPrimo) {
            QRCodeScannerView { result in
                if let contenuto = result {
                    anteprimaDati = ItinerarioEstratto.parse(from: contenuto)
                    anteprimaIndex = 1
                }
                mostraScannerPrimo = false
            }
        }
        .sheet(isPresented: $mostraScannerSecondo) {
            QRCodeScannerView { result in
                if let contenuto = result {
                    anteprimaDati = ItinerarioEstratto.parse(from: contenuto)
                    anteprimaIndex = 2
                }
                mostraScannerSecondo = false
            }
        }
        .sheet(item: $viaggioDaMostrare) { viaggio in
            DettaglioViaggioView(viaggio: viaggio)
        }
        .sheet(item: $anteprimaDati) { dati in
            AnteprimaItinerarioView(dati: dati) {
                if anteprimaIndex == 1 {
                    primoBiglietto = dati.raw
                } else if anteprimaIndex == 2 {
                    pendingSecondoBiglietto = dati.raw
                }
                anteprimaDati = nil
                anteprimaIndex = nil
            }
        }
        .onChange(of: pendingSecondoBiglietto) {
            guard let secondoRaw = pendingSecondoBiglietto, let partenzaRaw = primoBiglietto else { return }
            let primoEstratto = ItinerarioEstratto.parse(from: partenzaRaw)
            let secondoEstratto = ItinerarioEstratto.parse(from: secondoRaw)
            let scalo = primoEstratto.destinazione ?? "Scalo"
            let itinerarioString = (primoEstratto.partenza ?? "-") + " → " + (secondoEstratto.destinazione ?? primoEstratto.destinazione ?? "-")
            let viaggio = Viaggio(partenza: partenzaRaw, destinazione: secondoRaw, scalo: scalo, itinerario: itinerarioString)
            viaggi.append(viaggio)
            primoBiglietto = nil
            pendingSecondoBiglietto = nil
            viaggioDaMostrare = viaggio
        }
    }

    private func bigliettoButton(isPrimo: Bool) -> some View {
        VStack {
            Text(isPrimo ? "Scansiona il\nprimo biglietto" : "Scansiona il\nsecondo biglietto")
                .multilineTextAlignment(.center)
                .font(.body)
                .padding(.bottom, 8)
            Button(action: {
                if isPrimo {
                    mostraActionSheetPrimo = true
                } else {
                    mostraActionSheetSecondo = true
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(.systemGray6))
                        .frame(width: 120, height: 120)
                    Image(systemName: isPrimo ? (primoBiglietto == nil ? "qrcode.viewfinder" : "checkmark.seal.fill") : (primoBiglietto != nil ? "qrcode.viewfinder" : "lock"))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .foregroundColor(isPrimo || primoBiglietto != nil ? .mint : .gray)
                }
            }
            .disabled(!isPrimo && primoBiglietto == nil)
        }
    }

    private func makeViaggioRow(for viaggio: Viaggio) -> some View {
        let estratto = ItinerarioEstratto.parse(from: viaggio.partenza)
        let estrattoDest = ItinerarioEstratto.parse(from: viaggio.destinazione)

        let origine = estratto.partenza ?? "-"
        let destinazione = estrattoDest.destinazione ?? estratto.destinazione ?? "-"
        let tratta = "\(origine) → \(destinazione)"

        return ViaggioRow(
            viaggio: viaggio,
            passeggero: estratto.passeggero,
            tratta: tratta
        )
    }

    func riconosciCodiceDaImmagine(image: UIImage, isPrimo: Bool) {
        guard let cgImage = image.cgImage else { return }
        let request = VNDetectBarcodesRequest { request, _ in
            if let results = request.results as? [VNBarcodeObservation], let first = results.first, let payload = first.payloadStringValue {
                DispatchQueue.main.async {
                    anteprimaDati = ItinerarioEstratto.parse(from: payload)
                    anteprimaIndex = isPrimo ? 1 : 2
                }
            }
        }
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
}

struct ViaggioRow: View {
    let viaggio: Viaggio
    let passeggero: String?
    let tratta: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(passeggero ?? tratta)
                Text(viaggio.itinerario)
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

#if DEBUG
struct ScansioneView_Previews: PreviewProvider {
    static var previews: some View {
        ScansioneView()
    }
}
#endif
