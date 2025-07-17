//
//  ScansioneView.swift
//  SwiftApp
//
//  Created by Studente on 04/07/25.
//

import SwiftUI
import AVFoundation
import Foundation

struct ScansioneView: View {
    @State private var viaggi: [Viaggio] = []
    @State private var primoBiglietto: String? = nil
    @State private var mostraScannerPrimo = false
    @State private var mostraScannerSecondo = false
    @State private var viaggioDaMostrare: Viaggio? = nil
    @State private var anteprimaDati: ItinerarioEstratto? = nil
    @State private var anteprimaIndex: Int? = nil
    @State private var pendingSecondoBiglietto: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Scan biglietti")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 24)
                .padding(.horizontal)
            Divider()
                .padding(.bottom, 16)
            HStack(spacing: 32) {
                VStack {
                    Text("Scansiona il\nprimo biglietto")
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .padding(.bottom, 8)
                    Button(action: { mostraScannerPrimo = true }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color(.systemGray6))
                                .frame(width: 120, height: 120)
                            Image(systemName: primoBiglietto == nil ? "qrcode.viewfinder" : "checkmark.seal.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 72, height: 72)
                                .foregroundColor(primoBiglietto == nil ? .black : .mint)
                        }
                    }
                }
                VStack {
                    Text("Scansiona il\nsecondo biglietto")
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .padding(.bottom, 8)
                    Button(action: { mostraScannerSecondo = true }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color(.systemGray6))
                                .frame(width: 120, height: 120)
                            Image(systemName: primoBiglietto != nil ? "qrcode.viewfinder" : "lock")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 72, height: 72)
                                .foregroundColor(primoBiglietto != nil ? .black : .gray)
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
                .padding(.horizontal)
                .padding(.bottom, 8)
            List {
                ForEach(viaggi) { viaggio in
                    HStack {
                        let estratto = ItinerarioEstratto.parse(from: viaggio.partenza)
                        let estrattoDest = ItinerarioEstratto.parse(from: viaggio.destinazione)
                        VStack(alignment: .leading) {
                            if let passeggero = estratto.passeggero {
                                Text(passeggero)
                                    .fontWeight(.semibold)
                            }
                            HStack(spacing: 8) {
                                if let partenza = estratto.partenza {
                                    Text(partenza)
                                        .foregroundColor(.mint)
                                }
                                Image(systemName: "arrow.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                if let destinazione = estrattoDest.destinazione ?? estratto.destinazione {
                                    Text(destinazione)
                                        .foregroundColor(.mint)
                                }
                                if let orario = estratto.info?["orario"], !orario.isEmpty {
                                    Text("\(orario)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .onTapGesture { viaggioDaMostrare = viaggio }
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
            let viaggio = Viaggio(partenza: partenzaRaw, destinazione: secondoRaw, scalo: scalo)
            viaggi.append(viaggio)
            primoBiglietto = nil
            pendingSecondoBiglietto = nil
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
        VStack(spacing: 0) {
            Text("Dettaglio Viaggio")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 24)
            Spacer().frame(height: 12)
            // Timeline verticale
            VStack(alignment: .center, spacing: 0) {
                TimelineStepView(
                    title: "Partenza",
                    code: estrattoPartenza.partenza ?? "-",
                    time: estrattoPartenza.info?["orario"],
                    icon: "airplane.departure",
                    color: .mint,
                    subtitle: estrattoPartenza.info?["volo"],
                    extra: estrattoPartenza.info?["compagnia"]
                )
                TimelineConnector()
                TimelineStepView(
                    title: "Scalo",
                    code: (!scalo.isEmpty && scalo != "Scalo") ? scalo : "-",
                    time: nil,
                    icon: "arrow.triangle.branch",
                    color: .orange,
                    subtitle: nil,
                    extra: nil
                )
                TimelineConnector()
                TimelineStepView(
                    title: "Destinazione",
                    code: estrattoDest.destinazione ?? estrattoPartenza.destinazione ?? "-",
                    time: estrattoDest.info?["orario"],
                    icon: "flag.checkered",
                    color: .blue,
                    subtitle: estrattoDest.info?["volo"],
                    extra: estrattoDest.info?["compagnia"]
                )
            }
            .padding(.vertical, 16)
            // Nome passeggero sotto la timeline
            if let passeggero = estrattoPartenza.passeggero {
                HStack(spacing: 8) {
                    Image(systemName: "person.fill")
                        .foregroundColor(.mint)
                    Text(passeggero)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .padding(.top, 16)
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
                    .opacity(0.7)
            })
            .disabled(true)
            .padding(.top, 24)
            Spacer()
        }
        .padding()
    }
}

// Timeline step view arricchita
struct TimelineStepView: View {
    let title: String
    let code: String
    let time: String?
    let icon: String
    let color: Color
    let subtitle: String?
    let extra: String?
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
                if let subtitle = subtitle, !subtitle.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "number")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("Volo: \(subtitle)")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
                if let extra = extra, !extra.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "airplane")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("Compagnia: \(extra)")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
                if let time = time, !time.isEmpty {
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
        .padding(.vertical, 14)
        .background(Color(.systemGray6))
        .cornerRadius(18)
        .shadow(color: color.opacity(0.08), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 8)
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
