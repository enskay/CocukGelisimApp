import Foundation
import FirebaseAuth
import FirebaseFirestore

class LoginViewModel: ObservableObject {
    // Kullanıcı giriş durumu ve bilgileri
    @Published var isLoggedIn: Bool = false        // Giriş yapıldı mı?
    @Published var isTeacher: Bool = false         // Giriş yapan öğretmen mi (true) yoksa veli mi (false)?
    @Published var email: String = ""              // (Öğretmen için) Giriş e-postası
    @Published var password: String = ""           // (Öğretmen için) Giriş şifresi
    @Published var girisKodu: String = ""          // (Veli için) 4 haneli giriş kodu
    @Published var hataMesaji: String = ""         // Giriş sırasında oluşan hata mesajı
    @Published var currentVeliID: String? = nil    // Veli girişi yapıldıysa o velinin Firestore belge ID'si

    // Firebase Authentication kullanarak öğretmen girişi yap
    func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                // Hata durumunda hata mesajını yayınla
                DispatchQueue.main.async {
                    self?.hataMesaji = "Giriş hatası: \(error.localizedDescription)"
                }
            } else {
                // Giriş başarılı
                DispatchQueue.main.async {
                    self?.isTeacher = true       // Öğretmen rolünü ata
                    self?.isLoggedIn = true      // Giriş yapıldı olarak işaretle
                    self?.hataMesaji = ""        // Hata mesajını temizle
                    // Gerekirse burada öğretmen kullanıcı bilgilerini Firestore'dan çekebilirsiniz
                }
            }
        }
    }

    // Firestore kullanarak 4 haneli kod ile veli girişi yap
    func signInWithCode() {
        // Firestore'dan "veliler" koleksiyonunda girilen kodu arıyoruz
        let db = Firestore.firestore()
        db.collection("veliler").whereField("giris_kodu", isEqualTo: girisKodu).getDocuments { [weak self] snapshot, error in
            if let error = error {
                // Firestore hatası
                DispatchQueue.main.async {
                    self?.hataMesaji = "Giriş hatası: \(error.localizedDescription)"
                }
            } else {
                // Sorgu başarılı, kod eşleşen veli var mı?
                if let docs = snapshot?.documents, !docs.isEmpty {
                    // Eşleşen ilk veli belgesini al
                    let veliDoc = docs[0]
                    // Veli belgesinin ID'sini ve gerekli verilerini al
                    DispatchQueue.main.async {
                        self?.currentVeliID = veliDoc.documentID   // Mevcut velinin Firestore ID'sini sakla
                        self?.isTeacher = false    // Veli rolünü ata
                        self?.isLoggedIn = true    // Giriş yapıldı
                        self?.hataMesaji = ""      // Hata mesajını temizle
                        // Not: Gerekirse burada veliye ait verileri (örn. isim, çocuk bilgisi) alıp saklayabilirsiniz.
                    }
                } else {
                    // Hiçbir veli belgesi bu kodla bulunamadı (geçersiz kod)
                    DispatchQueue.main.async {
                        self?.hataMesaji = "Geçersiz giriş kodu. Lütfen kodu kontrol edin."
                    }
                }
            }
        }
    }

    // Oturum kapatma fonksiyonu (hem öğretmen hem veli için)
    func signOut() {
        // Firebase Auth oturumunu sonlandır (öğretmen giriş yaptıysa etkiler, veli için bir etkisi yok)
        try? Auth.auth().signOut()
        // Uygulama durumunu sıfırla
        DispatchQueue.main.async {
            self.isLoggedIn = false
            self.isTeacher = false
            self.currentVeliID = nil
            // Giriş ekranı alanlarını temizle
            self.email = ""
            self.password = ""
            self.girisKodu = ""
            self.hataMesaji = ""
        }
    }
}
