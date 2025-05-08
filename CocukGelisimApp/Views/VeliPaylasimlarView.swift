//
//  VeliPaylasimlarView.swift
//  CocukGelisimApp
//
//  Created by Ekrem on 8.05.2025.
//


import SwiftUI
import FirebaseFirestore

struct VeliPaylasimlarView: View {
    @State private var paylasimlar: [Duyuru] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(paylasimlar) { duyuru in
                    VStack(alignment: .leading, spacing: 8) {
                        if let url = URL(string: duyuru.gorselURL), !duyuru.gorselURL.isEmpty {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 180)
                                    .clipped()
                                    .cornerRadius(12)
                            } placeholder: {
                                ProgressView()
                            }
                        }

                        Text(duyuru.baslik)
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text(duyuru.aciklama)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("🕒 \(duyuru.olusturulmaTarihi)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 3)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Paylaşımlar")
        .onAppear {
            paylasimlariYukle()
        }
    }

    private func paylasimlariYukle() {
        let db = Firestore.firestore()
        db.collection("duyurular")
            .order(by: "tarih", descending: true)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else { return }
                self.paylasimlar = docs.map { doc in
                    let data = doc.data()
                    return Duyuru(
                        id: doc.documentID,
                        baslik: data["baslik"] as? String ?? "-",
                        aciklama: data["aciklama"] as? String ?? "-",
                        gorselURL: data["gorselURL"] as? String ?? "",
                        olusturulmaTarihi: (data["tarih"] as? Timestamp)?.dateValue().formatted(date: .abbreviated, time: .shortened) ?? "-"
                    )
                }
            }
    }
}