//
//  MapView.swift
//  SwiftApp
//
//  Created by Studente on 11/07/25.
//

import SwiftUI

struct MapView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack{
            HStack{
                Spacer()
                Button(action:{dismiss()}){
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.mint)
                        .font(.system(size: 30))
                }
                .padding(.horizontal,40)
            }
            Spacer()
        }
    }
}

#Preview {
    MapView()
}
