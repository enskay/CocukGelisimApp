import Foundation
import FirebaseFirestore

class AdminSeansListViewModel: ObservableObject {
    @Published var seanslar: [Seans] = []
    @Published var ogretmenFiltre: String = "Tümü" // "Tümü", "Alper", "Elif"

    private let db = Firestore.firestore()

    func seanslariYukle() {
        db.collection("seanslar").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { return }

            DispatchQueue.main.async {
                let filtrelenmis: [Seans] = docs.compactMap { doc in
                    let d = doc.data()
                    let ogretmenID = d["ogretmen_id"] as? String ?? ""

                    // Öğretmen filtreleme
                    if self.ogretmenFiltre == "Alper", ogretmenID != "ZZ3PM4pTkEefhmcm6JB4BXsltgu2" { return nil }
                    if self.ogretmenFiltre == "Elif", ogretmenID != "TVLwEsZhJuUUQrUpRSKk1jiufBv2" { return nil }

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
                        ogretmenID: ogretmenID
                    )
                }

                self.seanslar = filtrelenmis
            }
        }
    }

    func sadeceSeansiSil(seansID: String) {
        db.collection("seanslar").document(seansID).delete()
    }

    func seansiSilVeErtelemeDusur(seans: Seans) {
        db.collection("seanslar").document(seans.id).delete()

        if seans.tur == "Grup" {
            let ogrenciRef = db.collection("ogrenciler").document(seans.ogrenciID)
            ogrenciRef.getDocument { doc, _ in
                if let data = doc?.data(),
                   var kalan = data["kalan_erteleme"] as? Int {
                    kalan = max(kalan - 1, 0)
                    ogrenciRef.updateData(["kalan_erteleme": kalan])
                }
            }
        }
    }

    func seansDurumuGuncelle(seansID: String, yeniDurum: String, ogrenciID: String) {
        db.collection("seanslar").document(seansID).updateData(["durum": yeniDurum])

        if yeniDurum == "ertelendi" {
            db.collection("seanslar").document(seansID).getDocument { docSnap, _ in
                guard let data = docSnap?.data(),
                      let tur = data["tur"] as? String,
                      tur == "Grup" else { return }

                let ogrenciRef = self.db.collection("ogrenciler").document(ogrenciID)
                ogrenciRef.getDocument { snap, _ in
                    if let oData = snap?.data(),
                       var kalan = oData["kalan_erteleme"] as? Int {
                        kalan = max(kalan - 1, 0)
                        ogrenciRef.updateData(["kalan_erteleme": kalan])
                    }
                }
            }
        }
    }
}
