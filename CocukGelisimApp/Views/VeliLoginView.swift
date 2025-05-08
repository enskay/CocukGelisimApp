//
//  VeliLoginView.swift
//  CocukGelisimApp
//
//  Created by Ekrem on 8.05.2025.
//


import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct VeliLoginView: View {
    @State private var girisKodu = ""
    @State private var hataMesaji = ""
    @State private var girisBasarili = false

    var body: some View {
        VStack(spacing: 30) {
            Text("🔐 Veli Girişi")
                .font(.largeTitle.bold())

            TextField("4 Haneli Kod", text: $girisKodu)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            if !hataMesaji.isEmpty {
                Text(hataMesaji)
                    .foregroundColor(.red)
            }

            Button("Giriş Yap") {
                girisYap()
            }
            .buttonStyle(.borderedProminent)

            NavigationLink(destination: VeliTabView(), isActive: $girisBasarili) {
                EmptyView()
            }
        }
        .padding()
    }

    private func girisYap() {
        let db = Firestore.firestore()

        db.collection("veliler")
            .whereField("giris_kodu", isEqualTo: girisKodu)
            .getDocuments { snapshot, error in
                if let error = error {
                    self.hataMesaji = "Hata oluştu: \(error.localizedDescription)"
                    return
                }

                guard let docs = snapshot?.documents, let userDoc = docs.first else {
                    self.hataMesaji = "Geçersiz kod"
                    return
                }

                // Veli giriş başarılı: UID kaydet
                UserDefaults.standard.set(userDoc.documentID, forKey: "veliUID")
                self.girisBasarili = true
            }
    }
}