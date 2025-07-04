//
//  ListaItinerariView.swift
//  SwiftApp
//
//  Created by Studente on 04/07/25.
//

import SwiftUI

enum Categoria{case cibo,monumenti,natura,shopping}

struct Itinerario: Identifiable {
    var id = UUID()
    var citta: String
    var aeroporto: String
    var ore:Int
    var minuti:Int
    var categoria:Categoria
    var preferito:Bool=false
    
    func testo() -> String{
        if self.minuti<10{
            return "\(citta) - \(ore):0\(minuti) ore"
        }else{
            return "\(citta) - \(ore):\(minuti) ore"
        }
    }
}

func eliminaItinerario(){
    
}

struct ListaItinerariView: View {
    
    var itinerari:[Itinerario]=[Itinerario(citta: "Barcellona", aeroporto: "Aeropuertos de Barcelona", ore: 6, minuti: 0, categoria: .monumenti),Itinerario(citta: "Napoli", aeroporto: "Capodichino", ore: 2, minuti: 30, categoria: .cibo, preferito: true),Itinerario(citta: "Parigi", aeroporto: "Aeroporté de Paris", ore: 8, minuti: 20, categoria: .shopping)]
    var body: some View {
        NavigationStack{
            List{
                ForEach(itinerari) { itinerario in
                    if itinerario.preferito{
                            HStack{
                                VStack{
                                    Text(itinerario.testo())
                                    Text("\(itinerario.categoria)")
                                        .foregroundColor(.gray)
                                        
                                }
                                Spacer()
                                Image(systemName: "star.fill")
                                    .foregroundColor(.teal)
                            }
                    }else{
                        HStack{
                            VStack{
                                Text(itinerario.testo())
                                Text("\(itinerario.categoria)")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
            }
            .navigationTitle("Itinerari")
            .navigationBarTitleDisplayMode(.large)
        }
        
    }
}

#Preview {
    ListaItinerariView()
}
