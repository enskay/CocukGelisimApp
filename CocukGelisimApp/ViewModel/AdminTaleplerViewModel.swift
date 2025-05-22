// AdminTaleplerViewModel.swift
import Foundation
import FirebaseFirestore

class AdminTaleplerViewModel: ObservableObject {
    @Published var talepler: [OgretmenSeansTalebi] = []

    func talepleriYukle() {
        Firestore.firestore().collection("seans_talepleri").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else {
                self.talepler = []
                return
            }

            self.talepler = docs.compactMap { doc in
                let d = doc.data()
                let isim = d["ogrenci_ismi"] as? String ?? "-"
                return OgretmenSeansTalebi(
                    id: doc.documentID,
                    tarih: d["tarih"] as? String ?? "-",
                    saat: d["saat"] as? String ?? "-",
                    ogrenciID: d["ogrenci_id"] as? String ?? "",
                    ogrenciIsmi: isim.isEmpty ? "Bilinmiyor" : isim,
                    ogretmenID: d["ogretmen_id"] as? String ?? "",
                    ogretmenIsmi: d["ogretmen_ismi"] as? String ?? "-",
                    tur: d["tur"] as? String ?? "-"
                )
            }
        }
    }

    func talebiOnayla(talep: OgretmenSeansTalebi, completion: @escaping (Bool) -> Void) {
        let seansVeri: [String: Any] = [
            "tarih": talep.tarih,
            "saat": talep.saat,
            "ogrenci_id": talep.ogrenciID,
            "ogrenci_ismi": talep.ogrenciIsmi,
            "ogretmen_id": talep.ogretmenID,
            "ogretmen_ismi": talep.ogretmenIsmi,
            "tur": talep.tur,
            "durum": "bekliyor",
            "onaylandi": true
        ]

        let db = Firestore.firestore()
        db.collection("seanslar").addDocument(data: seansVeri) { error in
            if error == nil {
                db.collection("seans_talepleri").document(talep.id).delete()
                self.talepleriYukle()
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    func talebiReddet(talep: OgretmenSeansTalebi, completion: @escaping (Bool) -> Void) {
        Firestore.firestore().collection("seans_talepleri").document(talep.id).delete { error in
            if error == nil {
                self.talepleriYukle()
                completion(true)
            } else {
                completion(false)
            }
        }
    }
} 
