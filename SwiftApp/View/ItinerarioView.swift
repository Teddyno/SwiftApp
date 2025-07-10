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
                    .frame(height:2)
                    .background(.black)
                Text("Itinerario")
                VStack(alignment: .leading){
                    ForEach($itinerario.tappe){$tappa in
                        HStack(alignment: .center){
                            let i=itinerario.tappe.firstIndex(of: tappa)!
                            Button(action: {progresso=i}){
                                Image(systemName: i>progresso ? "xmark.circle.fill" : "checkmark.circle.fill")
                                    .foregroundColor(i>progresso ? .gray : .mint)
                                    .font(.system(size: 24))
                                
                            }
                            Text("\(tappa.oraArrivo)")
                                .font(.system(size: 24))
                                .fontWeight(.bold)
                            VStack(alignment: .leading){
                                Text("\(tappa.nome)")
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
                    }
                    .padding()
                }
            }
            Spacer()
        }
        .onAppear{
            open=Array(repeating: false, count: itinerario.tappe.count)
        }
        
    }

}

#Preview {
    ItinerarioView(itinerario: .constant(Itinerario(citta: "Barcellona", aeroporto: "Aeropuertos de Barcelona", ore: 6, minuti: 0, categoria: .monumenti,tappe: [
        Tappa(
            nome: "Sagrada Família",
            descr: "La basilica iconica di Antoni Gaudí, capolavoro in costruzione dal 1882.",
            oraArrivo: "09:00",
            foto: Image("sagrada_familia"),
            maps: "https://maps.apple.com/?q=Sagrada+Familia"
        ),
        Tappa(
            nome: "Passeig de Gràcia",
            descr: "Elegante via dello shopping e dell'architettura modernista, con Casa Batlló e Casa Milà.",
            oraArrivo: "10:30",
            foto: Image("passeig_de_gracia"),
            maps: "https://maps.apple.com/?q=Passeig+de+Gracia"
        ),
        Tappa(
            nome: "Mercato della Boqueria",
            descr: "Mercato storico e colorato lungo La Rambla, ideale per uno spuntino.",
            oraArrivo: "12:00",
            foto: Image("mercato_boqueria"),
            maps: "https://maps.apple.com/?q=Mercado+de+La+Boqueria"
        ),
        Tappa(
            nome: "Barceloneta",
            descr: "Passeggiata rilassante lungo la spiaggia più famosa di Barcellona.",
            oraArrivo: "13:30",
            foto: Image("barceloneta"),
            maps: "https://maps.apple.com/?q=Barceloneta"
        )
    ])))
}
