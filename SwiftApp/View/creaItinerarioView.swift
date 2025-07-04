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
    
    let preferenze = ["Natura","Cibo","Monumenti","Shopping"]
    
    var body: some View {
        ZStack{
            VStack{
                Image("sfondo")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius:60))
                    .ignoresSafeArea()
                Spacer()
            }
            
            VStack(){
                
                HStack{
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.mint)
                    TextField("città/aeroporto", text: $luogoScalo)
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(16)
                .padding(.horizontal, 35)
               
                
                HStack{
                    Image(systemName: "clock")
                        .foregroundColor(.mint)
                    Text("Durata scalo")
                        .font(.headline)
                        .padding(.leading)
                    DatePicker("",
                               selection: $durataScalo,
                               displayedComponents: [.hourAndMinute])
                    
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .padding(.horizontal, 35)
                .padding(.top,10)
                
                
                VStack() {
                    Text("Scegli uno tra questi interessi")
                        .font(.headline)

                    LazyVGrid(columns: [GridItem(spacing: 15), GridItem()],
                              spacing: 15) {
                        ForEach(preferenze, id: \.self) { interest in
                            Button(action: {
                                preferenzaSelezionata = interest
                            }) {
                                Text(interest)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .padding(.top,15)
                                    .padding(.bottom,15)
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
                .cornerRadius(16)
                .padding(.horizontal, 35)
                .padding(.top, 50)
                
                Spacer()
                
                Button(action: {}) {
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
        }
    }
}

#Preview {
    creaItinerarioView()
}
