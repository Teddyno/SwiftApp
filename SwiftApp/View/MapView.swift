//
//  MapView.swift
//  SwiftApp
//
//  Created by Studente on 11/07/25.
//

import SwiftUI
import MapKit

struct MapView: View {
    @Environment(\.dismiss) var dismiss
    var tappe: [Tappa] = []
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 41.9028, longitude: 12.4964),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )
    
    var body: some View {
        ZStack(alignment: .top) {
            // Mappa con bordo arrotondato e ombra su device grandi
            GeometryReader { geo in
                Map(position: $cameraPosition) {
                    ForEach(tappeWithCoords()) { tappa in
                        Annotation(tappa.nome, coordinate: tappa.coordinate) {
                            VStack(spacing: 0) {
                                ZStack {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.system(size: 36))
                                        .foregroundColor(.mint)
                                        .shadow(color: .mint.opacity(0.3), radius: 6, x: 0, y: 4)
                                    if let idx = tappeWithCoords().firstIndex(where: { $0.id == tappa.id }) {
                                        Text("\(idx+1)")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .offset(y: 2)
                                    }
                                }
                                Text(tappa.nome)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(.systemBackground).opacity(0.85))
                                            .shadow(radius: 2)
                                    )
                                    .padding(.top, 2)
                            }
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: geo.size.width > 500 ? 32 : 0))
                .shadow(color: .black.opacity(geo.size.width > 500 ? 0.12 : 0), radius: geo.size.width > 500 ? 16 : 0)
                .edgesIgnoringSafeArea(.all)
            }
            // Barra superiore con sfondo sfumato e titolo grande
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 32, weight: .bold))
                            .shadow(radius: 2)
                            .padding(.trailing, 18)
                            .padding(.top, 32)
                    }
                    .padding(.trailing, 18)
                    .padding(.top, 32)
                }
            }
        }
        .onAppear {
            if let first = tappeWithCoords().first {
                cameraPosition = .region(MKCoordinateRegion(center: first.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)))
            }
        }
    }
    
    struct TappaMap: Identifiable {
        let id = UUID()
        let nome: String
        let coordinate: CLLocationCoordinate2D
    }
    func tappeWithCoords() -> [TappaMap] {
        tappe.map { tappa in
            let coords = coordsForTappa(tappa)
            return TappaMap(nome: tappa.nome, coordinate: coords)
        }
    }
    func coordsForTappa(_ tappa: Tappa) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: tappa.latitudine, longitude: tappa.longitudine)
    }
}

#Preview {
    MapView(tappe: [
        Tappa(nome: "Sagrada Família", descr: "", oraArrivo: "09:00", foto: "", maps: "", latitudine: 41.4036, longitudine: 2.1744),
        Tappa(nome: "Barceloneta", descr: "", oraArrivo: "13:30", foto: "", maps: "", latitudine: 41.3786, longitudine: 2.1896),
        Tappa(nome: "Mercato della Boqueria", descr: "", oraArrivo: "12:00", foto: "", maps: "", latitudine: 0.0, longitudine: 0.0),
        Tappa(nome: "Passeig de Gràcia", descr: "", oraArrivo: "10:30", foto: "", maps: "",latitudine: 0.0, longitudine: 0.0)
    ])
}
