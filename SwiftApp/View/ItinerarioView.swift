//
//  ItinerarioView.swift
//  SwiftApp
//
//  Created by Studente on 04/07/25.
//

import SwiftUI

struct ItinerarioView: View {
    @Binding var itinerario: Itinerario
    @State var progresso=0
    @State var open:[Bool]=[]
    @State var mostraMap=false
    var body: some View {
        NavigationStack{
            VStack{
                Text("\(itinerario.testo())")
                    .font(.system(size: 24))
                    .fontWeight(.bold)
                Text("\(itinerario.aeroporto)")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                Divider()
                    .frame(height:1)
                    .background(.black)
                
                ScrollView{
                    ScrollView(.horizontal,showsIndicators: false){
                        HStack(spacing: 18){
                            let totalSteps=itinerario.tappe.count
                            ForEach(0..<totalSteps, id: \.self) { index in
                                Button(action: { withAnimation(.spring()) { progresso = index } }) {
                                    VStack(spacing: 4){
                                        if !itinerario.tappe.isEmpty{
                                            Text("\(itinerario.tappe[index].oraArrivo)")
                                                .frame(width:58)
                                                .fontWeight(index == progresso ? .bold : .regular)
                                                .foregroundColor(index == progresso ? .mint : .gray)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.7)
                                                .animation(.easeInOut, value: progresso)
                                        }
                                        Circle()
                                            .fill(index <= progresso ? Color.mint : Color.gray.opacity(0.3))
                                            .frame(width: 30, height: 30)
                                            .overlay(
                                                Circle()
                                                    .stroke(index == progresso ? Color.mint : Color.clear, lineWidth: index == progresso ? 4 : 0)
                                                    .shadow(color: index == progresso ? Color.mint.opacity(0.4) : .clear, radius: 8, x: 0, y: 2)
                                            )
                                            .overlay(
                                                Text("\(index + 1)")
                                                    .font(.caption)
                                                    .foregroundColor(.white)
                                                    .fontWeight(.bold)
                                            )
                                            .animation(.spring(), value: progresso)
                                            .padding(4)
                                            .padding(.horizontal, 6)
                                    }
                                }
                                
                                if index < totalSteps - 1 {
                                    VStack{
                                        Text(".")
                                            .foregroundColor(.white)
                                        Rectangle()
                                            .fill(index < progresso ? Color.mint : Color.gray.opacity(0.3))
                                            .frame(height: 2)
                                            .frame(width: 35)
                                            .padding(0)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal,20)
                        .frame(minWidth: 400, alignment: .leading)
                    }
                    VStack(alignment: .leading){
                        ForEach($itinerario.tappe){$tappa in
                            let i=itinerario.tappe.firstIndex(of: tappa)!
                            VStack{
                                Divider()
                                HStack(alignment: .center){
                                    Button(action: {progresso=i}){
                                        Image(systemName: i>progresso ? "xmark.circle.fill" : "checkmark.circle.fill")
                                            .foregroundColor(i>progresso ? .gray : .mint)
                                            .font(.system(size: 24))
                                        
                                    }
                                    VStack(alignment: .leading){
                                        Text("\(tappa.oraArrivo) - \(tappa.nome)")
                                            .fontWeight(.bold)
                                            .font(.system(size: 20))
                                        Text("\(tappa.descr)")
                                            .foregroundColor(.gray)
                                        
                                    }
                                    Spacer()
                                    if !open.isEmpty && open[i]{
                                        Button(action:{open[i].toggle()}){
                                            VStack{Image(systemName: "chevron.down.circle")
                                                    .foregroundColor(.mint)
                                                    .font(.system(size: 24))
                                            }
                                        }
                                        
                                    }else if !open.isEmpty && !open[i]{
                                        Button(action:{open[i].toggle()}){
                                            Image(systemName: "chevron.right.circle")
                                                .foregroundColor(.mint)
                                                .font(.system(size: 24))
                                        }
                                    }
                                }
                                if !open.isEmpty && open[i]{
                                     HStack {
                                         Spacer()
                                         VStack(spacing: 12) {
                                             Image("\(tappa.foto)")
                                                 .resizable()
                                                 .scaledToFill()
                                                 .frame(maxWidth: 900, maxHeight: 600)
                                                 .cornerRadius(16)
                                             let url: URL = {
                                                 func appleMapsURL(from original: String, nome: String, citta: String?) -> URL {
                                                     if original.contains("maps.app.goo.gl") || original.contains("google.com/maps") {
                                                         let query = (nome + (citta != nil ? ", " + citta! : "")).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? nome
                                                         return URL(string: "http://maps.apple.com/?q=\(query)")!
                                                     }
                                                     if let u = URL(string: original), UIApplication.shared.canOpenURL(u) {
                                                         return u
                                                     }
                                                     return URL(string: "http://maps.apple.com/?q=Piazza+Navona+Roma")!
                                                 }
                                                 return appleMapsURL(from: tappa.maps, nome: tappa.nome, citta: itinerario.citta)
                                             }()
                                             Link("Apri in Mappe", destination: url)
                                                 .foregroundColor(.blue)
                                                 .font(.system(size:20))
                                         }
                                         .padding()
                                         .background(Color(.systemBackground).opacity(0.95))
                                         .cornerRadius(20)
                                         .shadow(radius: 8)
                                         Spacer()
                                     }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            Spacer()
        }
        .onAppear{
            open=Array(repeating: false, count: itinerario.tappe.count)
        }
        .toolbar{
            ToolbarItem(placement: .topBarTrailing){
                Button(action:{mostraMap=true}){
                    Image(systemName: "mappin.and.ellipse")
                }
            }
        }
        .sheet(isPresented: $mostraMap){
            MapView(tappe: itinerario.tappe)
        }
        
    }

}

#Preview {
    ItinerarioView(itinerario: .constant(Itinerario(
        citta: "Barcellona",
        aeroporto: "Aeropuertos de Barcelona",
        ore: 6,
        minuti: 0,
        categoria: .monumenti,
        tappe: [
            Tappa(
                nome: "Sagrada Família",
                descr: "La basilica iconica di Antoni Gaudí, capolavoro in costruzione dal 1882.",
                oraArrivo: "09:00",
                foto: "sagrada_familia",
                maps: "https://maps.apple.com/?q=Sagrada+Familia",
                latitudine: 41.4036,
                longitudine: 2.1744
            ),
            Tappa(
                nome: "Passeig de Gràcia",
                descr: "Elegante via dello shopping e dell'architettura modernista, con Casa Batlló e Casa Milà.",
                oraArrivo: "10:30",
                foto: "passeig_de_gracia",
                maps: "https://maps.apple.com/?q=Passeig+de+Gracia",
                latitudine: 41.3917,
                longitudine: 2.1649
            ),
            Tappa(
                nome: "Mercato della Boqueria",
                descr: "Mercato storico e colorato lungo La Rambla, ideale per uno spuntino.",
                oraArrivo: "12:00",
                foto: "mercato_boqueria",
                maps: "https://maps.apple.com/?q=Mercado+de+La+Boqueria",
                latitudine: 41.3826,
                longitudine: 2.1722
            ),
            Tappa(
                nome: "Barceloneta",
                descr: "Passeggiata rilassante lungo la spiaggia più famosa di Barcellona.",
                oraArrivo: "13:30",
                foto: "barceloneta",
                maps: "https://maps.apple.com/?q=Barceloneta",
                latitudine: 41.3766,
                longitudine: 2.1925
            )
        ]
    )))

}
