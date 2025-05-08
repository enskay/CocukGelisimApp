import Foundation
import FirebaseFirestore

class VeliHomeViewModel: ObservableObject {
    @Published var duyurular: [Duyuru] = []

    func duyuruYukle() {
        let db = Firestore.firestore()
        db.collection("duyurular")
            .order(by: "tarih", descending: true)
            .limit(to: 5)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else { return }

                self.duyurular = docs.map { doc in
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
