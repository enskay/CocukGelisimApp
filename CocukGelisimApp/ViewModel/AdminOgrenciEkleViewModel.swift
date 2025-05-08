import Foundation
import FirebaseFirestore

class AdminOgrenciEkleViewModel: ObservableObject {
    @Published var yeniKod: String = ""
    @Published var kodOlustuAlert: Bool = false
    @Published var hataAlert: Bool = false
    @Published var hataMesaji: String?

    func addStudent(parentName: String, childName: String, ageText: String, email: String) {
        let db = Firestore.firestore()
        let yeniOgrenciRef = db.collection("ogrenciler").document()
        let yeniOgrenciID = yeniOgrenciRef.documentID

        guard let yasInt = Int(ageText) else {
            self.hataMesaji = "Yaş bilgisi geçerli değil."
            self.hataAlert = true
            return
        }

        let dogumTarihi = Calendar.current.date(byAdding: .month, value: -yasInt, to: Date()) ?? Date()

        let ogrenciVeri: [String: Any] = [
            "isim": childName,
            "dogumTarihi": Timestamp(date: dogumTarihi),
            "kalan_erteleme": 2,
            "kullanilan_hak": 0,
            "birebir_limit": 6
        ]

        yeniOgrenciRef.setData(ogrenciVeri) { err in
            if let err = err {
                self.hataMesaji = "Öğrenci eklenemedi: \(err.localizedDescription)"
                self.hataAlert = true
                return
            }

            let girisKodu = String(Int.random(in: 1000...9999))

            let veliVeri: [String: Any] = [
                "veliAdi": parentName,
                "giris_kodu": girisKodu,
                "ogrenci_id": yeniOgrenciID
            ]

            db.collection("veliler").addDocument(data: veliVeri) { err in
                if let err = err {
                    self.hataMesaji = "Veli eklenemedi: \(err.localizedDescription)"
                    self.hataAlert = true
                    return
                }

                DispatchQueue.main.async {
                    self.yeniKod = girisKodu
                    self.kodOlustuAlert = true
                }
            }
        }
    }
}
