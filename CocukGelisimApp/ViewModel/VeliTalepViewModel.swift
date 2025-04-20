//
//  VeliTalepViewModel.swift
//  CocukGelisimApp
//
//  Created by Ekrem on 18.04.2025.
//


import Foundation
import FirebaseFirestore

class VeliTalepViewModel: ObservableObject {
    @Published var doluTarihler: [String] = []

    func doluGunleriYukle() {
        let db = Firestore.firestore()
        db.collection("seanslar").getDocuments { snapshot, _ in
            guard let docs = snapshot?.documents else { return }

            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd"

            self.doluTarihler = docs.compactMap {
                $0.data()["tarih"] as? String
            }
        }
    }

    func talepGonder(tarih: String, neden: String?, ogrenciID: String, ogrenciIsmi: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let data: [String: Any] = [
            "tarih": tarih,
            "neden": neden ?? "",
            "ogrenci_id": ogrenciID,
            "ogrenci_ismi": ogrenciIsmi
        ]

        db.collection("seans_talepleri").addDocument(data: data) { error in
            completion(error == nil)
        }
    }
}
