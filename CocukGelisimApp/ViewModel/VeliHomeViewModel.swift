import Foundation
import FirebaseFirestore

class VeliHomeViewModel: ObservableObject {
    @Published var duyurular: [Duyuru] = []

    func duyurulariYukle() {
        let db = Firestore.firestore()
        db.collection("duyurular").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { return }

            self.duyurular = docs.map { doc in
                let d = doc.data()
                return Duyuru(
                    id: doc.documentID,
                    baslik: d["baslik"] as? String ?? "-",
                    icerik: d["icerik"] as? String ?? "-"
                )
            }
        }
    }
}
