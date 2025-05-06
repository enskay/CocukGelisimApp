//
//  AdminOgrenciEkleViewModel.swift
//  CocukGelisimApp
//
//  Created by Enes  on 6.05.2025.
//


import Foundation
import FirebaseFirestore

class AdminOgrenciEkleViewModel: ObservableObject {
    @Published var yeniKod: String = ""             // Oluşturulan yeni kod
    @Published var kodOlustuAlert: Bool = false     // Kod oluştu uyarısı gösterilsin mi?
    @Published var hataMesaji: String? = nil        // Hata mesajı (varsa)
    @Published var hataAlert: Bool = false          // Hata uyarısı gösterilsin mi?

    // Yeni öğrenci ve veli kaydı ekleme fonksiyonu
    func addStudent(parentName: String, childName: String, ageText: String, email: String) {
        // Girişlerin doğrulanması
        if parentName.isEmpty || childName.isEmpty || ageText.isEmpty {
            self.hataMesaji = "Lütfen tüm alanları doldurun."
            self.hataAlert = true
            return
        }
        guard let age = Int(ageText) else {
            self.hataMesaji = "Yaş alanına sayı giriniz."
            self.hataAlert = true
            return
        }
        // Firestore işlemleri
        let db = Firestore.firestore()
        // Önce benzersiz 4 haneli kod oluştur
        generateUniqueCode(db: db) { [weak self] kod in
            guard let self = self, let kod = kod else {
                // Kod oluşturulamadı (ör. ağ hatası)
                self?.hataMesaji = "Kod oluşturulamadı. Lütfen tekrar deneyin."
                self?.hataAlert = true
                return
            }
            // Yeni veliler belgesi oluştur
            let yeniBelge = db.collection("veliler").document()
            let yeniVeri: [String: Any] = [
                "ogrenci_id": yeniBelge.documentID,   // Öğrenci ID (belge ID'si kullanıldı)
                "ogrenci_ismi": childName,
                "veli_ismi": parentName,
                "email": email,
                "yas": age,
                "giris_kodu": kod
            ]
            // Veriyi Firestore'a yaz
            yeniBelge.setData(yeniVeri) { error in
                if let error = error {
                    // Kayıt başarısız
                    DispatchQueue.main.async {
                        self.hataMesaji = "Kayıt başarısız: \(error.localizedDescription)"
                        self.hataAlert = true
                    }
                } else {
                    // Kayıt başarılı, oluşturulan kodu kullanıcıya göster
                    DispatchQueue.main.async {
                        self.yeniKod = kod
                        self.kodOlustuAlert = true
                    }
                }
            }
        }
    }

    // 4 haneli benzersiz kod üretme (veritabanında zaten kullanılmayan)
    private func generateUniqueCode(db: Firestore, completion: @escaping (String?) -> Void) {
        // 0000-9999 arası rastgele bir sayı oluşturup 4 haneli stringe çeviriyoruz
        let kod = String(format: "%04d", Int.random(in: 0...9999))
        // Firestore'da bu kod var mı kontrol et
        db.collection("veliler").whereField("giris_kodu", isEqualTo: kod).getDocuments { snapshot, error in
            if let error = error {
                print("Kod kontrolünde hata: \(error.localizedDescription)")
                completion(nil)
            } else if let docs = snapshot?.documents, !docs.isEmpty {
                // Bu kod zaten kullanılmış, yeniden üret
                self.generateUniqueCode(db: db, completion: completion)
            } else {
                // Kod benzersiz, kullanılabilir
                completion(kod)
            }
        }
    }
}