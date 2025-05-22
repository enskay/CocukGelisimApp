import Foundation
import FirebaseFirestore

class AdminSeansListViewModel: ObservableObject {
    @Published var seanslar: [Seans] = []
    @Published var ogretmenFiltre: String = "Tümü"  // "Alper", "Elif", "Tümü"

    func seanslariYukle() {
        let db = Firestore.firestore()

        db.collection("seanslar")
            .order(by: "tarih", descending: false)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("❌ Seanslar getirilemedi")
                    return
                }

                var tumSeanslar: [Seans] = []

                for doc in documents {
                    let data = doc.data()

                    let seans = Seans(
                        id: doc.documentID,
                        ogrenciIsmi: data["ogrenci_ismi"] as? String ?? "-",
                        tarih: data["tarih"] as? String ?? "-",
                        saat: data["saat"] as? String ?? "--:--",
                        tur: data["tur"] as? String ?? "-",
                        durum: data["durum"] as? String ?? "bekliyor",
                        onaylandi: data["onaylandi"] as? Bool ?? false,
                        neden: data["neden"] as? String,
                        ogrenciID: data["ogrenci_id"] as? String ?? "",
                        ogretmenID: data["ogretmen_id"] as? String ?? "",
                        ogretmenIsmi: data["ogretmen_ismi"] as? String ?? "-"
                    )

                    tumSeanslar.append(seans)
                }

                // 🔍 Filtre uygula
                let filtreliSeanslar = tumSeanslar.filter { seans in
                    switch self.ogretmenFiltre {
                    case "Alper":
                        return seans.ogretmenID == "ZZ3PM4pTkEefhmcm6JB4BXsltgu2"
                    case "Elif":
                        return seans.ogretmenID == "TVLwEsZhJuUUQrUpRSKk1jiufBv2"
                    default:
                        return true
                    }
                }

                DispatchQueue.main.async {
                    self.seanslar = filtreliSeanslar
                }
            }
    }
}
