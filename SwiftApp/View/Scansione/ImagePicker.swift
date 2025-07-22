// ImagePicker.swift
// Componente UIKit wrapper per la selezione di immagini dalla galleria (UIImagePickerController).
// Utilizzato in ScansioneView.swift per permettere all'utente di selezionare un file immagine da cui estrarre un codice QR/barcode.
// Fornisce un binding a UIImage? e gestisce la chiusura del picker e il passaggio dell'immagine selezionata.

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    // Binding all'immagine selezionata
    @Binding var image: UIImage?
    
    // Coordinator per gestire i delegate UIKit
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    // Crea il picker UIKit
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    // Non serve aggiornare la view controller
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    // Coordinator per gestire la selezione/cancellazione
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image // Passa l'immagine selezionata al binding
            }
            picker.dismiss(animated: true)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
} 