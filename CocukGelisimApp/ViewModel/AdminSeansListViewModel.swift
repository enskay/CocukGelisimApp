import Foundation
import FirebaseFirestore

class AdminSeansListViewModel: ObservableObject {
    let db = Firestore.firestore()

    func seansDurumuGuncelle(seansID: String, yeniDurum: String, ogrenciID: String) {
        // 1. Seansı güncelle
        db.collection("seanslar").document(seansID).updateData([
            "durum": yeniDurum
        ]) { error in
            guard error == nil else { return }

            // 2. Öğrenci belgesini güncelle
            let ref = self.db.collection("ogrenciler").document(ogrenciID)
            ref.getDocument { doc, err in
                guard let data = doc?.data(),
                      var kullanilan = data["kullanilan_hak"] as? Int,
                      var kalanErteleme = data["kalan_erteleme"] as? Int else { return }

                switch yeniDurum {
                case "katıldı":
                    kullanilan += 1
                    ref.updateData(["kullanilan_hak": kullanilan])
                case "ertelendi":
                    if kalanErteleme > 0 {
                        kalanErteleme -= 1
                        ref.updateData(["kalan_erteleme": kalanErteleme])
                    }
                case "gelmedi":
                    kullanilan += 1
                    ref.updateData(["kullanilan_hak": kullanilan])
                default:
                    break
                }
            }
        }
    }
}
