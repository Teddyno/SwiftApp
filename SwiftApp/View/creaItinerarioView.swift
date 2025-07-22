//
//  creaItinerarioView.swift
//  SwiftApp
//
//  Created by Studente on 04/07/25.
//

import SwiftUI

struct creaItinerarioView: View {
    
    @State var luogoScalo: String = ""
    @State var durataScalo: Date  = Calendar.current.date(
        bySettingHour: 0,
        minute: 0,
        second: 0,
        of: Date()
    )!
    @State var durataMinuti: Int = 0
    @State var preferenzaSelezionata: String? = nil
    
    @State var aeroporti: [Aeroporto] = []
    @State var risultatiFiltrati: [Aeroporto] = []
    
    let preferenze = ["Natura", "Cibo", "Monumenti", "Shopping"]
    
    var body: some View {
        ZStack {
            VStack {
                Image("sfondo")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 50))
                    .ignoresSafeArea()
                Spacer()
            }
            
            VStack {
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.mint)
                        TextField("città/aeroporto", text: $luogoScalo)
                            .onChange(of: luogoScalo) { oldValue, newValue in
                                if newValue.isEmpty {
                                    risultatiFiltrati = []
                                } else {
                                    risultatiFiltrati = aeroporti.filter {
                                        $0.city.localizedCaseInsensitiveContains(newValue) ||
                                        $0.name.localizedCaseInsensitiveContains(newValue) ||
                                        $0.iata.localizedCaseInsensitiveContains(newValue)
                                    }.prefix(5).map { $0 }
                                }
                            }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 35)
                .padding(.top, 10)
                
                // Durata scalo
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.mint)
                    Text("Durata scalo")
                        .font(.headline)
                        .padding(.leading)
                        .foregroundColor(.gray)
                    DatePicker("", selection: $durataScalo, displayedComponents: [.hourAndMinute])
                        .colorMultiply(.black)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .padding(.horizontal, 35)
                .padding(.top, 10)
                
                // Preferenze
                VStack {
                    Text("Scegli uno tra questi interessi")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    LazyVGrid(columns: [GridItem(spacing: 15), GridItem()],
                              spacing: 15) {
                        ForEach(preferenze, id: \.self) { interest in
                            Button(action: {
                                preferenzaSelezionata = interest
                            }) {
                                Text(interest)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .padding(.top, 15)
                                    .padding(.bottom, 15)
                                    .background(preferenzaSelezionata == interest ? Color.mint : Color.gray.opacity(0.2))
                                    .foregroundColor(preferenzaSelezionata == interest ? .white : .gray)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(30)
                .padding(.horizontal, 35)
                .padding(.top, 40)
                
                Spacer()
                
                Button(action: {
                    // Azione per generare itinerario
                }) {
                    Text("Genera itinerario")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mint)
                        .cornerRadius(20)
                        .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 4)
                }
                .padding(.horizontal, 35)
                .padding(.bottom, 50)
            }
            .padding(.top, 90)
            
            // Lista suggerimenti posizionata in modo assoluto
            VStack {
                if !risultatiFiltrati.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(risultatiFiltrati) { aeroporto in
                            Button(action: {
                                luogoScalo = aeroporto.displayName
                                risultatiFiltrati = []
                                hideKeyboard()
                            }) {
                                Text(aeroporto.displayName)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white)
                                    .foregroundColor(.black)
                            }
                            if aeroporto.id != risultatiFiltrati.last?.id {
                                Divider()
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                    .padding(.horizontal, 35)
                    .padding(.top, 170) // Posiziona sotto al TextField
                } else {
                    Spacer()
                }
                Spacer()
            }
            .zIndex(1) // Assicura che sia sopra gli altri elementi
        }
        .background(Color.white)
        .onAppear {
            aeroporti = caricaAeroporti()
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    creaItinerarioView()
}
