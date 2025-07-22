// QRCodeScannerView.swift
// UIViewControllerRepresentable che integra AVFoundation per la scansione di QR code e barcode tramite fotocamera.
// Espone una closure di completion per restituire il risultato della scansione.
// Implementa ScannerViewControllerDelegate per comunicare il risultato al coordinatore SwiftUI.
// Supporta vari formati di barcode (QR, PDF417, Aztec, Code128, ecc.).

import SwiftUI
import AVFoundation

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
                    .qr, .pdf417, .aztec, .code128, .code39, .code93, .ean13, .ean8, .upce, .itf14, .dataMatrix
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

#if DEBUG
struct QRCodeScannerView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Preview QRCodeScannerView (non funzionante in simulatore)")
            QRCodeScannerView { _ in }
                .frame(height: 300)
        }
    }
}
#endif 