import Foundation
import FirebaseFirestore

class AdminSeansListViewModel: ObservableObject {
    @Published var seanslar: [Seans] = []
    private let db = Firestore.firestore()

    func seanslariYukle() {
        db.collection("seanslar").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { return }

            DispatchQueue.main.async {
                self.seanslar = docs.map { doc in
                    let d = doc.data()
                    return Seans(
                        id: doc.documentID,
                        ogrenciIsmi: d["ogrenci_ismi"] as? String ?? "-",
                        tarih: d["tarih"] as? String ?? "-",
                        saat: d["saat"] as? String ?? "--:--",
                        tur: d["tur"] as? String ?? "-",
                        durum: d["durum"] as? String ?? "bekliyor",
                        onaylandi: d["onaylandi"] as? Bool ?? false,
                        neden: d["neden"] as? String,
                        ogrenciID: d["ogrenci_id"] as? String ?? "",
                        ogretmenID: d["ogretmen_id"] as? String ?? ""
                    )
                }
            }
        }
    }

    func seansDurumuGuncelle(seansID: String, yeniDurum: String, ogrenciID: String) {
        db.collection("seanslar").document(seansID).updateData([
            "durum": yeniDurum
        ])
    }

    func seansiSil(seansID: String) {
        db.collection("seanslar").document(seansID).delete()
    }
}
