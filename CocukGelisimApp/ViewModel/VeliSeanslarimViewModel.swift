import Foundation
import FirebaseFirestore

class VeliSeanslarimViewModel: ObservableObject {
    @Published var grupSeanslar: [String: [Seans]] = [:]
    @Published var birebirSeanslar: [String: [Seans]] = [:]
    @Published var tarihListesi: [String] = []
    @Published var isLoading = false

    let loginVM: LoginViewModel

    init(loginVM: LoginViewModel) {
        self.loginVM = loginVM
    }

    func seanslariYukle() {
        guard let veliID = loginVM.currentVeliID else {
            print("🔥 Giriş yapan veli ID'si bulunamadı")
            return
        }
        let db = Firestore.firestore()
        db.collection("veliler").document(veliID).getDocument { docSnap, _ in
            guard let data = docSnap?.data(),
                  let ogrenciID = data["ogrenci_id"] as? String else {
                print("🔥 Öğrenci ID alınamadı")
                return
            }
            db.collection("seanslar")
                .whereField("ogrenci_id", isEqualTo: ogrenciID)
                .getDocuments { snap, error in
                    guard let docs = snap?.documents else {
                        print("🔥 Seanslar getirilemedi")
                        return
                    }
                    var grup: [String: [Seans]] = [:]
                    var birebir: [String: [Seans]] = [:]
                    var tumTarihler: Set<String> = []
                    for doc in docs {
                        let d = doc.data()
                        let tarihStr = d["tarih"] as? String ?? "-"
                        let displayTarih = Self.tarihGosterimi(tarihStr)
                        let seans = Seans(
                            id: doc.documentID,
                            ogrenciIsmi: d["ogrenci_ismi"] as? String ?? "-",
                            tarih: tarihStr,
                            saat: d["saat"] as? String ?? "--:--",
                            tur: d["tur"] as? String ?? "-",
                            durum: d["durum"] as? String ?? "bekliyor",
                            onaylandi: d["onaylandi"] as? Bool ?? false,
                            neden: d["neden"] as? String,
                            ogrenciID: d["ogrenci_id"] as? String ?? "",
                            ogretmenID: d["ogretmen_id"] as? String ?? "",
                            ogretmenIsmi: d["ogretmen_ismi"] as? String ?? "Öğretmen"
                        )
                        tumTarihler.insert(displayTarih)
                        if seans.tur.lowercased() == "grup" {
                            grup[displayTarih, default: []].append(seans)
                        } else {
                            birebir[displayTarih, default: []].append(seans)
                        }
                    }
                    DispatchQueue.main.async {
                        self.grupSeanslar = grup
                        self.birebirSeanslar = birebir
                        self.tarihListesi = tumTarihler.sorted()
                    }
                }
        }
    }

    func seansiIptalEt(seans: Seans, completion: @escaping () -> Void) {
        isLoading = true
        let db = Firestore.firestore()
        db.collection("seanslar").document(seans.id).updateData([
            "durum": "iptal"
        ]) { err in
            if let err = err {
                print("Seans iptal edilirken hata:", err.localizedDescription)
                DispatchQueue.main.async { self.isLoading = false }
                completion()
                return
            }
            db.collection("ogrenciler").document(seans.ogrenciID).getDocument { docSnap, _ in
                guard let ogrData = docSnap?.data(),
                      var toplamHak = ogrData["toplam_hak"] as? Int else {
                    print("Toplam hak okunamadı")
                    DispatchQueue.main.async { self.isLoading = false }
                    self.seanslariYukle()
                    completion()
                    return
                }
                toplamHak += 1
                db.collection("ogrenciler").document(seans.ogrenciID).updateData([
                    "toplam_hak": toplamHak
                ]) { hata in
                    if let hata = hata {
                        print("Hak güncellenirken hata:", hata.localizedDescription)
                    }
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.seanslariYukle()
                        completion()
                    }
                }
            }
        }
    }

    static func tarihGosterimi(_ tarihStr: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "tr_TR")
        displayFormatter.dateFormat = "dd MMMM yyyy, EEEE"
        if let date = inputFormatter.date(from: tarihStr) {
            return displayFormatter.string(from: date)
        }
        return tarihStr
    }
}
