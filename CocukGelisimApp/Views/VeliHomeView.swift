//
//  VeliHomeView.swift
//  CocukGelisimApp
//
//  Created by Ekrem on 18.04.2025.
//


import SwiftUI
import FirebaseFirestore

struct VeliHomeView: View {
    @StateObject private var viewModel = VeliHomeViewModel()

    var body: some View {
        NavigationStack {
            List(viewModel.duyurular) { duyuru in
                VStack(alignment: .leading, spacing: 6) {
                    Text(duyuru.baslik)
                        .font(.headline)
                    Text(duyuru.icerik)
                        .font(.subheadline)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Duyurular")
            .onAppear {
                viewModel.duyurulariYukle()
            }
        }
    }
}
