import Foundation
import FirebaseFirestore


class AdminTaleplerViewModel: ObservableObject {
    @Published var talepler: [SeansTalebi] = []
    private let db = Firestore.firestore()

    func talepleriYukle() {
        db.collection("seans_talepleri").getDocuments { snapshot, _ in
            guard let docs = snapshot?.documents else { return }

            self.talepler = docs.map { doc in
                let d = doc.data()
                return SeansTalebi(
                    id: doc.documentID,
                    ogrenciID: d["ogrenci_id"] as? String ?? "",
                    ogrenciIsmi: d["ogrenci_ismi"] as? String ?? "-",
                    tarih: d["tarih"] as? String ?? "-",
                    neden: d["neden"] as? String ?? ""
                )
            }
        }
    }

    func onaylaKaydi(talep: SeansTalebi, ogretmenID: String) {
        let yeniSeans: [String: Any] = [
            "tarih": talep.tarih,
            "saat": "Belirlenmedi",
            "ogrenci_id": talep.ogrenciID,
            "ogrenci_ismi": talep.ogrenciIsmi,
            "tur": "Birebir",
            "durum": "bekliyor",
            "onaylandi": true,
            "ogretmen_id": ogretmenID,
            "neden": talep.neden
        ]

        db.collection("seanslar").addDocument(data: yeniSeans) { err in
            if err == nil {
                self.db.collection("seans_talepleri").document(talep.id).delete()
                DispatchQueue.main.async {
                    self.talepler.removeAll { $0.id == talep.id }
                }
            }
        }
    }

    func reddet(talep: SeansTalebi) {
        db.collection("seans_talepleri").document(talep.id).delete { _ in
            DispatchQueue.main.async {
                self.talepler.removeAll { $0.id == talep.id }
            }
        }
    }
}
