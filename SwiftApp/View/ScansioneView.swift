//
//  ScansioneView.swift
//  SwiftApp
//
//  Created by Studente on 04/07/25.
//

import SwiftUI
import AVFoundation
import Foundation
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
    
    // Viaggi di esempio
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
                VStack {
                    Text("Scansiona il\nprimo biglietto")
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .padding(.bottom, 8)
                        Button(action: { mostraActionSheetPrimo = true }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color(.systemGray6))
                                .frame(width: 120, height: 120)
                            Image(systemName: primoBiglietto == nil ? "qrcode.viewfinder" : "checkmark.seal.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 72, height: 72)
                                    .foregroundColor(.mint)
                            }
                    }
                }
                VStack {
                    Text("Scansiona il\nsecondo biglietto")
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .padding(.bottom, 8)
                        Button(action: { mostraActionSheetSecondo = true }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color(.systemGray6))
                                .frame(width: 120, height: 120)
                            Image(systemName: primoBiglietto != nil ? "qrcode.viewfinder" : "lock")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 72, height: 72)
                                    .foregroundColor(primoBiglietto != nil ? .mint : .gray)
                            }
                        }
                        .disabled(primoBiglietto == nil)
                }
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
                    HStack {
                        VStack(alignment: .leading) {
                                    let estratto = ItinerarioEstratto.parse(from: viaggio.partenza)
                                    let estrattoDest = ItinerarioEstratto.parse(from: viaggio.destinazione)
                                    // Titolo principale: passeggero o tratta
                                    if let passeggero = estratto.passeggero {
                                        Text(passeggero)
                                    } else {
                                        Text((estratto.partenza ?? "-") + " → " + (estrattoDest.destinazione ?? estratto.destinazione ?? "-"))
                                    }
                                    // Sottotitolo: categoria o info
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
        // ActionSheet per il primo biglietto
        .confirmationDialog("Scegli sorgente", isPresented: $mostraActionSheetPrimo, titleVisibility: .visible) {
            Button("Fotocamera") { mostraScannerPrimo = true }
            Button("File") {
                imagePickerForPrimo = true
                mostraImagePicker = true
            }
            Button("Annulla", role: .cancel) {}
        }
        // ActionSheet per il secondo biglietto
        .confirmationDialog("Scegli sorgente", isPresented: $mostraActionSheetSecondo, titleVisibility: .visible) {
            Button("Fotocamera") { mostraScannerSecondo = true }
            Button("File") {
                imagePickerForPrimo = false
                mostraImagePicker = true
            }
            Button("Annulla", role: .cancel) {}
        }
        // ImagePicker
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
                // conferma
                if anteprimaIndex == 1 {
                    primoBiglietto = dati.raw
                } else if anteprimaIndex == 2 {
                    pendingSecondoBiglietto = dati.raw
                }
                anteprimaDati = nil
                anteprimaIndex = nil
            }
        }
        .onChange(of: pendingSecondoBiglietto) { oldValue, newValue in
            guard let secondoRaw = newValue, let partenzaRaw = primoBiglietto else { return }
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
    // Funzione per riconoscere codice da immagine
    func riconosciCodiceDaImmagine(image: UIImage, isPrimo: Bool) {
        guard let cgImage = image.cgImage else { return }
        let request = VNDetectBarcodesRequest { request, error in
            if let results = request.results as? [VNBarcodeObservation], let first = results.first, let payload = first.payloadStringValue {
                DispatchQueue.main.async {
                    anteprimaDati = ItinerarioEstratto.parse(from: payload)
                    anteprimaIndex = isPrimo ? 1 : 2
                }
            } else {
                // Nessun codice trovato
                // Potresti mostrare un alert
            }
        }
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
}

#Preview {
    ScansioneView()
}

// MARK: - QRCodeScannerView
import AVFoundation
import SwiftUI

struct QRCodeScannerView: UIViewControllerRepresentable {
    var completion: (String?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = ScannerViewController()
        controller.completion = completion
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    class Coordinator: NSObject, ScannerViewControllerDelegate {
        let parent: QRCodeScannerView
        init(parent: QRCodeScannerView) { self.parent = parent }
        func didFind(code: String) {
            parent.completion(code)
        }
        func didFail() {
            parent.completion(nil)
        }
    }
}

protocol ScannerViewControllerDelegate: AnyObject {
    func didFind(code: String)
    func didFail()
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var completion: ((String?) -> Void)?
    weak var delegate: ScannerViewControllerDelegate?
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        // Tutta la configurazione della sessione su thread in background
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
                DispatchQueue.main.async { self.delegate?.didFail() }
                return
        }
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
                DispatchQueue.main.async { self.delegate?.didFail() }
                return
        }
            if self.captureSession.canAddInput(videoInput) {
                self.captureSession.addInput(videoInput)
        } else {
                DispatchQueue.main.async { self.delegate?.didFail() }
                return
        }
        let metadataOutput = AVCaptureMetadataOutput()
            if self.captureSession.canAddOutput(metadataOutput) {
                self.captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [
                    .qr,
                    .pdf417,
                    .aztec,
                    .code128,
                    .code39,
                    .code93,
                    .ean13,
                    .ean8,
                    .upce,
                    .itf14,
                    .dataMatrix
                ]
        } else {
                DispatchQueue.main.async { self.delegate?.didFail() }
                return
            }
            self.captureSession.startRunning()
            // PreviewLayer va aggiornata sul main thread
            DispatchQueue.main.async {
                self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                self.previewLayer.frame = self.view.layer.bounds
                self.previewLayer.videoGravity = .resizeAspectFill
                self.view.layer.addSublayer(self.previewLayer)
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession?.stopRunning()
    }
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject, let stringValue = metadataObject.stringValue {
            delegate?.didFind(code: stringValue)
        } else {
            delegate?.didFail()
        }
        dismiss(animated: true)
    }
}

// MARK: - DettaglioViaggioView
struct DettaglioViaggioView: View {
    let viaggio: Viaggio
    var body: some View {
        let estrattoPartenza = ItinerarioEstratto.parse(from: viaggio.partenza)
        let estrattoDest = ItinerarioEstratto.parse(from: viaggio.destinazione)
        let scalo = viaggio.scalo
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 0) {
                Text("Dettaglio Viaggio")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 32)
                    .padding(.bottom, 12)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                VStack(spacing: 0) {
                    TimelineStepCard(
                        title: "Partenza",
                        code: estrattoPartenza.partenza ?? "-",
                        time: estrattoPartenza.info?["orario"],
                        icon: "airplane.departure",
                        color: .mint
                    )
                    TimelineConnector()
                    TimelineStepCard(
                        title: "Scalo",
                        code: (!scalo.isEmpty && scalo != "Scalo") ? scalo : "-",
                        time: nil,
                        icon: "arrow.triangle.branch",
                        color: .orange
                    )
                    TimelineConnector()
                    TimelineStepCard(
                        title: "Destinazione",
                        code: estrattoDest.destinazione ?? estrattoPartenza.destinazione ?? "-",
                        time: estrattoDest.info?["orario"],
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
                Spacer()
                Button(action: {}, label: {
                    Text("Genera itinerario")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 40)
                        .background(Color.mint)
                        .cornerRadius(20)
                })
                .disabled(true)
                .padding(.bottom, 32)
            }
        }
    }
}

// Card orizzontale per la timeline
struct TimelineStepCard: View {
    let title: String
    let code: String
    let time: String?
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
                if let time = time {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("Orario: \(time)")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(24)
        .padding(.vertical, 10)
    }
}

// Timeline connector (linea verticale)
struct TimelineConnector: View {
    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 3, height: 24)
            .padding(.leading, 28)
    }
}

// MARK: - Parsing e anteprima
struct ItinerarioEstratto: Identifiable {
    let id = UUID()
    let raw: String
    let partenza: String?
    let destinazione: String?
    let passeggero: String?
    let compagnia: String?
    let info: [String: String]?
    static func parse(from text: String) -> ItinerarioEstratto {
        // Prova parser custom
        if let dati = estraiDatiDa(text) {
            let orario = estraiOrarioVoloDa(text)
            var info: [String: String] = [:]
            if let orario = orario { info["orario"] = orario }
            return ItinerarioEstratto(
                raw: text,
                partenza: dati.partenza,
                destinazione: dati.destinazione,
                passeggero: "\(dati.cognome) \(dati.nome)",
                compagnia: nil,
                info: info
            )
        }
        // BCBP (IATA): inizia con M1
        if text.starts(with: "M1") && text.count >= 60 {
            // Nome passeggero: da 2 a 22 (20 caratteri, riempito di spazi)
            let nameStart = text.index(text.startIndex, offsetBy: 2)
            let nameEnd = text.index(text.startIndex, offsetBy: 22)
            let passeggero = String(text[nameStart..<nameEnd]).trimmingCharacters(in: .whitespaces)
            // Codice aeroporto partenza: 15-17
            let partenza = String(text[text.index(text.startIndex, offsetBy: 15)..<text.index(text.startIndex, offsetBy: 18)])
            // Codice aeroporto destinazione: 18-20
            let destinazione = String(text[text.index(text.startIndex, offsetBy: 18)..<text.index(text.startIndex, offsetBy: 21)])
            // Compagnia aerea: 21-23
            let compagnia = String(text[text.index(text.startIndex, offsetBy: 21)..<text.index(text.startIndex, offsetBy: 24)]).trimmingCharacters(in: .whitespaces)
            // Numero volo: 24-28
            let volo = String(text[text.index(text.startIndex, offsetBy: 24)..<text.index(text.startIndex, offsetBy: 29)]).trimmingCharacters(in: .whitespaces)
            // Data (opzionale, posizione 36-38, formato: giorno dell'anno)
            let dataGiornoAnno = String(text[text.index(text.startIndex, offsetBy: 36)..<text.index(text.startIndex, offsetBy: 39)])
            var info: [String: String] = [:]
            info["compagnia"] = compagnia
            info["volo"] = volo
            info["giornoAnno"] = dataGiornoAnno
            return ItinerarioEstratto(
                raw: text,
                partenza: partenza,
                destinazione: destinazione,
                passeggero: passeggero.isEmpty ? nil : passeggero,
                compagnia: compagnia.isEmpty ? nil : compagnia,
                info: info
            )
        }
        // JSON
        if let data = text.data(using: .utf8), let dict = try? JSONSerialization.jsonObject(with: data) as? [String: String] {
            return ItinerarioEstratto(
                raw: text,
                partenza: dict["partenza"] ?? dict["from"],
                destinazione: dict["destinazione"] ?? dict["to"],
                passeggero: dict["passeggero"] ?? dict["name"],
                compagnia: dict["compagnia"] ?? dict["company"],
                info: dict
            )
        }
        // Regex per pattern tipo 'from: FCO', 'to: JFK', 'name: Mario Rossi'
        func match(_ pattern: String) -> String? {
            if let r = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let m = r.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)),
               let range = Range(m.range(at: 1), in: text) {
                return String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
            return nil
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
        // fallback
        return ItinerarioEstratto(raw: text, partenza: nil, destinazione: nil, passeggero: nil, compagnia: nil, info: nil)
    }
}

func estraiDatiDa(_ stringa: String) -> (cognome: String, nome: String, partenza: String, destinazione: String)? {
    // 1. Trova "M1" e il blocco nome/cognome
    guard let rangeM1 = stringa.range(of: "M1") else { return nil }
    let dopoM1 = stringa[rangeM1.upperBound...]
    guard let fineNome = dopoM1.firstIndex(of: " ") else { return nil }
    let nomeCognomeRaw = dopoM1[..<fineNome]
    let nomeParts = nomeCognomeRaw.split(separator: "/")
    guard nomeParts.count == 2 else { return nil }
    let cognome = String(nomeParts[0])
    let nome = String(nomeParts[1])
    // 2. Cerca i codici aeroporti nel resto della stringa (6 lettere maiuscole dopo nome/cognome)
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
    // 1. Trova tutti i numeri da 3 o 4 cifre
    let pattern = "\\b\\d{3,4}\\b"
    let regex = try? NSRegularExpression(pattern: pattern)
    let nsrange = NSRange(testo.startIndex..., in: testo)
    let matches = regex?.matches(in: testo, range: nsrange) ?? []
    var orariValidi: [(posizione: Int, orario: String)] = []
    for match in matches {
        let numero = (testo as NSString).substring(with: match.range)
        guard let intVal = Int(numero) else { continue }
        let ore = intVal / 100
        let minuti = intVal % 100
        guard ore >= 0 && ore < 24 && minuti >= 0 && minuti < 60 else { continue }
        let orario = String(format: "%02d:%02d", ore, minuti)
        let posizione = match.range.location
        orariValidi.append((posizione, orario))
    }
    // 2. Dai priorità a orari vicini a parole chiave (es. "EK", "LH", ...)
    let paroleChiave = ["EK", "LH", "AZ", "AF", "FR", "U2", "VY", "JU", "KL", "AA", "BA"]
    var posizioneRiferimento: Int? = nil
    for keyword in paroleChiave {
        if let r = testo.range(of: keyword) {
            let pos = testo.distance(from: testo.startIndex, to: r.lowerBound)
            if posizioneRiferimento == nil || pos < posizioneRiferimento! {
                posizioneRiferimento = pos
            }
        }
    }
    if let posizioneRif = posizioneRiferimento {
        var minDiff = Int.max
        var orarioScelto: String? = nil
        for (pos, orario) in orariValidi {
            let diff = abs(pos - posizioneRif)
            if diff < minDiff {
                minDiff = diff
                orarioScelto = orario
            }
        }
        if let scelto = orarioScelto {
            return scelto
        }
    }
    // 3. Se non ci sono parole chiave, restituisci il primo orario plausibile
    return orariValidi.first?.orario
}

struct AnteprimaItinerarioView: View {
    let dati: ItinerarioEstratto
    let conferma: () -> Void
    @State private var copied = false
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
                Text("Partenza: \(p)")
            }
            if let d = dati.destinazione {
                Text("Destinazione: \(d)")
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

// ImagePicker UIKit wrapper
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            picker.dismiss(animated: true)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
