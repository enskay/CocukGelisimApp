import Foundation
import FirebaseAuth
import FirebaseFirestore

struct YenilemeTalebi: Identifiable {
    let id: String
    let veliAdi: String
}

class AdminMainViewModel: ObservableObject {

    @Published var teacherName: String = ""
    @Published var todaySessions: [Seans] = []
    @Published var yenilemeTalepleri: [YenilemeTalebi] = []

    private let db = Firestore.firestore()

    func fetchAdminVerileri() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("ogretmenler").document(uid).getDocument { docSnap, error in
            if let data = docSnap?.data() {
                self.teacherName = data["isim"] as? String ?? "Öğretmen"
            }
        }

        db.collection("seanslar").whereField("tarih", isEqualTo: self.bugununTarihi()).getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { return }

            self.todaySessions = docs.compactMap { doc in
                let data = doc.data()
                return Seans(
                    id: doc.documentID,
                    ogrenciIsmi: data["ogrenci_ismi"] as? String ?? "-",
                    tarih: data["tarih"] as? String ?? "-",
                    saat: data["saat"] as? String ?? "--:--",
                    tur: data["tur"] as? String ?? "-",
                    durum: data["durum"] as? String ?? "bekliyor",
                    onaylandi: data["onaylandi"] as? Bool ?? false,
                    neden: data["neden"] as? String,
                    ogrenciID: data["ogrenci_id"] as? String ?? ""
                )
            }
        }

        db.collection("veliler").whereField("talep_yenileme", isEqualTo: true).getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { return }

            self.yenilemeTalepleri = docs.compactMap { doc in
                let data = doc.data()
                return YenilemeTalebi(
                    id: doc.documentID,
                    veliAdi: data["veliAdi"] as? String ?? "Bilinmiyor"
                )
            }
        }
    }

    func onaylaKaydi(for veliID: String) {
        db.collection("veliler").document(veliID).updateData([
            "talep_yenileme": false,
            "kayit_yenilendi": true
        ]) { error in
            if error == nil {
                DispatchQueue.main.async {
                    self.yenilemeTalepleri.removeAll { $0.id == veliID }
                }
            }
        }
    }

    private func bugununTarihi() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
