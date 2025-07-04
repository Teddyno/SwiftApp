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
                Image("sfondo-2")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius:60))
                    .ignoresSafeArea()
                Spacer()
            }
            VStack{
                HStack{
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.teal)
                    TextField("città/europorto", text: $luogoScalo)
                }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding(.horizontal, 40)
                HStack{
                    Image(systemName: "clock")
                        .foregroundColor(.teal)
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
                    .padding(.horizontal, 40)
            }
        }
    }
}

#Preview {
    creaItinerarioView()
}
