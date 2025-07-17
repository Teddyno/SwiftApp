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
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.9028, longitude: 12.4964),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    var body: some View {
        ZStack(alignment: .top) {
            // Mappa con bordo arrotondato e ombra su device grandi
            GeometryReader { geo in
                Map(coordinateRegion: $region, annotationItems: tappeWithCoords()) { tappa in
                    MapAnnotation(coordinate: tappa.coordinate) {
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
                }
            }
        }
        .onAppear {
            if let first = tappeWithCoords().first {
                region.center = first.coordinate
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
        switch tappa.nome.lowercased() {
        // Barcellona
        case let n where n.contains("sagrada"): return CLLocationCoordinate2D(latitude: 41.4036, longitude: 2.1744)
        case let n where n.contains("barceloneta"): return CLLocationCoordinate2D(latitude: 41.3809, longitude: 2.1896)
        case let n where n.contains("boqueria"): return CLLocationCoordinate2D(latitude: 41.3826, longitude: 2.1722)
        case let n where n.contains("passeig"): return CLLocationCoordinate2D(latitude: 41.3917, longitude: 2.1650)
        case let n where n.contains("guell"): return CLLocationCoordinate2D(latitude: 41.4145, longitude: 2.1527)
        case let n where n.contains("batll"): return CLLocationCoordinate2D(latitude: 41.3916, longitude: 2.1649)
        // Parigi
        case let n where n.contains("eiffel"): return CLLocationCoordinate2D(latitude: 48.8584, longitude: 2.2945)
        case let n where n.contains("louvre"): return CLLocationCoordinate2D(latitude: 48.8606, longitude: 2.3376)
        case let n where n.contains("notre"): return CLLocationCoordinate2D(latitude: 48.8530, longitude: 2.3499)
        case let n where n.contains("montmartre"): return CLLocationCoordinate2D(latitude: 48.8867, longitude: 2.3431)
        case let n where n.contains("arco"): return CLLocationCoordinate2D(latitude: 48.8738, longitude: 2.2950)
        // Dublino
        case let n where n.contains("phoenix"): return CLLocationCoordinate2D(latitude: 53.3561, longitude: -6.3296)
        case let n where n.contains("trinity"): return CLLocationCoordinate2D(latitude: 53.3438, longitude: -6.2546)
        case let n where n.contains("guinness"): return CLLocationCoordinate2D(latitude: 53.3419, longitude: -6.2869)
        case let n where n.contains("stephen"): return CLLocationCoordinate2D(latitude: 53.3382, longitude: -6.2591)
        case let n where n.contains("temple"): return CLLocationCoordinate2D(latitude: 53.3456, longitude: -6.2649)
        // Praga
        case let n where n.contains("castello"): return CLLocationCoordinate2D(latitude: 50.0909, longitude: 14.4005)
        case let n where n.contains("ponte carlo"): return CLLocationCoordinate2D(latitude: 50.0865, longitude: 14.4114)
        case let n where n.contains("orologio"): return CLLocationCoordinate2D(latitude: 50.0870, longitude: 14.4208)
        case let n where n.contains("piazza della città vecchia"): return CLLocationCoordinate2D(latitude: 50.0875, longitude: 14.4213)
        case let n where n.contains("casa danzante"): return CLLocationCoordinate2D(latitude: 50.0755, longitude: 14.4143)
        // Roma
        case let n where n.contains("colosseo"): return CLLocationCoordinate2D(latitude: 41.8902, longitude: 12.4922)
        case let n where n.contains("fori"): return CLLocationCoordinate2D(latitude: 41.8925, longitude: 12.4853)
        case let n where n.contains("navona"): return CLLocationCoordinate2D(latitude: 41.8992, longitude: 12.4731)
        case let n where n.contains("pantheon"): return CLLocationCoordinate2D(latitude: 41.8986, longitude: 12.4768)
        case let n where n.contains("trevi"): return CLLocationCoordinate2D(latitude: 41.9009, longitude: 12.4833)
        default: return CLLocationCoordinate2D(latitude: 41.9028, longitude: 12.4964)
        }
    }
}

#Preview {
    MapView(tappe: [
        Tappa(nome: "Sagrada Família", descr: "", oraArrivo: "09:00", foto: "", maps: ""),
        Tappa(nome: "Barceloneta", descr: "", oraArrivo: "13:30", foto: "", maps: ""),
        Tappa(nome: "Mercato della Boqueria", descr: "", oraArrivo: "12:00", foto: "", maps: ""),
        Tappa(nome: "Passeig de Gràcia", descr: "", oraArrivo: "10:30", foto: "", maps: "")
    ])
}
