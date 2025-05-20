//
//  VeliKodGirisViewModel.swift
//  CocukGelisimApp
//
//  Created by Enes  on 20.05.2025.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore

class VeliKodGirisViewModel: ObservableObject {
    @Published var girisKodu: String = ""
    @Published var hataMesaji: String?
    @Published var girisBasarili: Bool = false

    func girisYap() {
        guard !girisKodu.isEmpty else {
            self.hataMesaji = "Lütfen 4 haneli kodu giriniz."
            return
        }

        // Firebase Authentication - anonim giriş
        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                self.hataMesaji = "Giriş başarısız: \(error.localizedDescription)"
                return
            }

            guard let uid = result?.user.uid else {
                self.hataMesaji = "Kullanıcı kimliği alınamadı."
                return
            }

            // Firestore'da giris_kodu kontrolü
            let db = Firestore.firestore()
            db.collection("veliler")
                .whereField("giris_kodu", isEqualTo: self.girisKodu)
                .getDocuments { snapshot, err in
                    if let err = err {
                        self.hataMesaji = "Veritabanı hatası: \(err.localizedDescription)"
                        return
                    }

                    guard let docs = snapshot?.documents, let doc = docs.first else {
                        self.hataMesaji = "Kod geçersiz. Lütfen tekrar deneyin."
                        return
                    }

                    // Eşleşen belge bulunduğunda giriş başarılı
                    self.girisBasarili = true
                }
        }
    }
}