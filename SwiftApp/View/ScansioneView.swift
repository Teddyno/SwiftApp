//
//  ScansioneView.swift
//  SwiftApp
//
//  Created by Studente on 04/07/25.
//

import SwiftUI
import AVFoundation

struct ScansioneView: View {
    @State private var viaggi: [Viaggio] = []
    @State private var primoBiglietto: String? = nil
    @State private var mostraScannerPrimo = false
    @State private var mostraScannerSecondo = false
    @State private var viaggioDaMostrare: Viaggio? = nil
    
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
                        VStack(alignment: .leading) {
                            Text("Da: \(viaggio.partenza)")
                            Text("A: \(viaggio.destinazione)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button(action: { viaggioDaMostrare = viaggio }) {
                            Text("Detail")
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .listStyle(.plain)
        }
        .sheet(isPresented: $mostraScannerPrimo) {
            QRCodeScannerView { result in
                if let contenuto = result {
                    primoBiglietto = contenuto
                }
                mostraScannerPrimo = false
            }
        }
        .sheet(isPresented: $mostraScannerSecondo) {
            QRCodeScannerView { result in
                if let contenuto = result, let partenza = primoBiglietto {
                    let viaggio = Viaggio(partenza: partenza, destinazione: contenuto)
                    viaggi.append(viaggio)
                    primoBiglietto = nil
                }
                mostraScannerSecondo = false
            }
        }
        .sheet(item: $viaggioDaMostrare) { viaggio in
            DettaglioViaggioView(viaggio: viaggio)
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
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            delegate?.didFail(); return
        }
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            delegate?.didFail(); return
        }
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            delegate?.didFail(); return
        }
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            delegate?.didFail(); return
        }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        captureSession.startRunning()
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
        VStack(spacing: 24) {
            Text("Dettaglio Viaggio")
                .font(.title)
                .fontWeight(.bold)
            Text("Partenza: \(viaggio.partenza)")
            Text("Scalo: \(viaggio.scalo)")
            Text("Destinazione: \(viaggio.destinazione)")
            Text("Itinerario: \(viaggio.itinerario)")
                .font(.body)
            Text("Creato il: \(viaggio.dataCreazione.formatted(date: .long, time: .shortened))")
                .font(.footnote)
                .foregroundColor(.gray)
            Spacer()
        }
        .padding()
    }
}
