import Foundation
import FirebaseFirestore

class VeliTalepViewModel: ObservableObject {
    @Published var doluTarihler: [String] = []
    @Published var doluSaatler: [String] = []
    @Published var tumSaatler: [String] = []
    @Published var ogretmenler: [(id: String, isim: String)] = []

    let girisYapanVeliID: String

    init(veliID: String) {
        self.girisYapanVeliID = veliID
        saatListesiOlustur()
    }

    func saatListesiOlustur() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        var saatler: [String] = []

        for hour in 9...18 {
            for minute in stride(from: 0, through: 45, by: 30) {
                if let date = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) {
                    saatler.append(formatter.string(from: date))
                }
            }
        }
        self.tumSaatler = saatler
    }

    func ogretmenleriYukle(completion: @escaping () -> Void) {
        Firestore.firestore().collection("ogretmenler").getDocuments { snap, _ in
            guard let docs = snap?.documents else { return }
            let liste = docs.map { doc in
                let data = doc.data()
                let isim = data["isim"] as? String ?? "-"
                return (doc.documentID, isim)
            }
            DispatchQueue.main.async {
                self.ogretmenler = liste
                completion()
            }
        }
    }

    func doluGunleriYukle() {
        Firestore.firestore().collection("seanslar").getDocuments { snap, _ in
            guard let docs = snap?.documents else { return }
            var tarihler: Set<String> = []

            for doc in docs {
                if let tarih = doc.data()["tarih"] as? String {
                    tarihler.insert(tarih)
                }
            }

            DispatchQueue.main.async {
                self.doluTarihler = Array(tarihler)
            }
        }
    }

    func doluSaatleriYukle(tarih: String, ogretmenID: String) {
        Firestore.firestore().collection("seanslar")
            .whereField("tarih", isEqualTo: tarih)
            .whereField("ogretmen_id", isEqualTo: ogretmenID)
            .getDocuments { snap, _ in
                guard let docs = snap?.documents else { return }
                let saatler = docs.map { $0.data()["saat"] as? String ?? "" }
                DispatchQueue.main.async {
                    self.doluSaatler = saatler
                }
            }
    }

    func talepGonder(
        tarih: String,
        saat: String,
        ogretmenID: String,
        ogretmenIsmi: String,
        tur: String,
        completion: @escaping (Bool) -> Void
    ) {
        let db = Firestore.firestore()
        let veliRef = db.collection("veliler").document(self.girisYapanVeliID)

        veliRef.getDocument { docSnapshot, error in
            if let error = error {
                print("❌ Firestore hatası: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let data = docSnapshot?.data(),
                  let ogrenciID = data["ogrenci_id"] as? String else {
                print("❌ ogrenci_id bulunamadı.")
                completion(false)
                return
            }

            db.collection("ogrenciler").document(ogrenciID).getDocument { ogrDoc, err in
                if let err = err {
                    print("❌ Öğrenci verisi alınamadı: \(err.localizedDescription)")
                    completion(false)
                    return
                }

                let ogrenciIsmi = ogrDoc?.data()?["isim"] as? String ?? "Bilinmiyor"

                let veri: [String: Any] = [
                    "tarih": tarih,
                    "saat": saat,
                    "ogrenci_id": ogrenciID,
                    "ogrenci_ismi": ogrenciIsmi,
                    "ogretmen_id": ogretmenID,
                    "ogretmen_ismi": ogretmenIsmi,
                    "onaylandi": false,
                    "durum": "talep",
                    "tur": tur
                ]

                db.collection("seans_talepleri").addDocument(data: veri) { err in
                    DispatchQueue.main.async {
                        completion(err == nil)
                    }
                }
            }
        }
    }
}
