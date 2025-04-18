import Foundation
import FirebaseFirestore


class VeliHomeViewModel: ObservableObject {
    @Published var duyurular: [Duyuru] = []
    private let db = Firestore.firestore()

    func duyurulariYukle() {
        db.collection("duyurular").order(by: "baslik").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { return }

            self.duyurular = docs.map { doc in
                let data = doc.data()
                return Duyuru(
                    id: doc.documentID,
                    baslik: data["baslik"] as? String ?? "-",
                    aciklama: data["aciklama"] as? String ?? "-",
                    gorselUrl: data["gorselUrl"] as? String
                )
            }
        }
    }
}
