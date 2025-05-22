import Foundation
import FirebaseFirestore
import FirebaseAuth

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var girisKodu = ""
    @Published var hataMesaji = ""
    @Published var isAdmin = false
    @Published var isLoggedIn = false
    @Published var currentVeliID: String? = nil

    func signInAdmin() {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.hataMesaji = "Giriş Hatası: \(error.localizedDescription)"
                return
            }

            guard let uid = result?.user.uid else {
                self?.hataMesaji = "Kullanıcı ID alınamadı."
                return
            }

            let db = Firestore.firestore()
            db.collection("ogretmenler").document(uid).getDocument { doc, error in
                if let doc = doc, doc.exists {
                    self?.isAdmin = true
                    self?.isLoggedIn = true
                } else {
                    self?.hataMesaji = "Bu kullanıcı admin değil."
                }
            }
        }
    }

    func signInWithCode(completion: @escaping () -> Void) {
        let db = Firestore.firestore()

        db.collection("veliler")
            .whereField("giris_kodu", isEqualTo: girisKodu)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    self?.hataMesaji = "Hata: \(error.localizedDescription)"
                    completion()
                    return
                }

                guard let doc = snapshot?.documents.first else {
                    self?.hataMesaji = "Kod bulunamadı."
                    completion()
                    return
                }

                self?.currentVeliID = doc.documentID
                self?.isLoggedIn = true
                completion()
            }
    }

    func cikisYap() {
        email = ""
        password = ""
        girisKodu = ""
        hataMesaji = ""
        isAdmin = false
        isLoggedIn = false
        currentVeliID = nil
        try? Auth.auth().signOut()
    }
}
