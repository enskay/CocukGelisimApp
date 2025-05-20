import Foundation
import FirebaseAuth
import FirebaseFirestore

class LoginViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var isTeacher: Bool = false
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var girisKodu: String = ""
    @Published var hataMesaji: String = ""
    @Published var currentVeliID: String? = nil

    func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.hataMesaji = "Giriş hatası: \(error.localizedDescription)"
                }
            } else {
                DispatchQueue.main.async {
                    self?.isTeacher = true
                    self?.isLoggedIn = true
                    self?.hataMesaji = ""
                }
            }
        }
    }

    func signInWithCode() {
        let db = Firestore.firestore()
        db.collection("veliler").whereField("giris_kodu", isEqualTo: girisKodu).getDocuments { [weak self] snapshot, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.hataMesaji = "Giriş hatası: \(error.localizedDescription)"
                }
            } else {
                if let docs = snapshot?.documents, !docs.isEmpty {
                    let veliDoc = docs[0]
                    DispatchQueue.main.async {
                        self?.currentVeliID = veliDoc.documentID
                        self?.isTeacher = false
                        self?.isLoggedIn = true
                        self?.hataMesaji = ""
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.hataMesaji = "Geçersiz giriş kodu. Lütfen kontrol edin."
                    }
                }
            }
        }
    }

    func signOut() {
        try? Auth.auth().signOut()
        DispatchQueue.main.async {
            self.isLoggedIn = false
            self.isTeacher = false
            self.currentVeliID = nil
            self.email = ""
            self.password = ""
            self.girisKodu = ""
            self.hataMesaji = ""
        }
    }
}
