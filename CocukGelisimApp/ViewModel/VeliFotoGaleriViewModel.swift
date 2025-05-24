import Foundation
import FirebaseFirestore

class VeliFotoGaleriViewModel: ObservableObject {
    @Published var fotograflar: [GaleriFoto] = []

    func fotograflariYukle() {
        let db = Firestore.firestore()
        db.collection("foto_galeri")
            .order(by: "tarih", descending: true)
            .getDocuments { snap, error in
                guard let docs = snap?.documents else { return }
                let list = docs.compactMap { doc -> GaleriFoto? in
                    let d = doc.data()
                    guard let url = d["url"] as? String,
                          let baslik = d["baslik"] as? String,
                          let aciklama = d["aciklama"] as? String,
                          let yukleyen = d["yukleyen"] as? String,
                          let tarih = d["tarih"] as? Timestamp else { return nil }
                    return GaleriFoto(
                        id: doc.documentID,
                        url: url,
                        baslik: baslik,
                        aciklama: aciklama,
                        yukleyen: yukleyen,
                        tarih: tarih.dateValue()
                    )
                }
                DispatchQueue.main.async {
                    self.fotograflar = list
                }
            }
    }
}
