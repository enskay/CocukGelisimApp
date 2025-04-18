import Foundation
import FirebaseAuth
import FirebaseFirestore

class LoginViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var isTeacher = false
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var hataMesaji: String = ""

    func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.hataMesaji = "Giriş hatası: \(error.localizedDescription)"
                }
                return
            }

            guard let uid = result?.user.uid else { return }
            self.isLoggedIn = true

            let db = Firestore.firestore()
            db.collection("ogretmenler").document(uid).getDocument { snapshot, _ in
                self.isTeacher = snapshot?.exists == true
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isLoggedIn = false
            self.isTeacher = false
            self.email = ""
            self.password = ""
        } catch {
            print("Çıkış hatası: \(error)")
        }
    }
}
