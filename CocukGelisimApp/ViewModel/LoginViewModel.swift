import Foundation
import FirebaseAuth
import FirebaseFirestore

class LoginViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var loginStatusMessage = ""
    @Published var isLoggedIn = false
    @Published var isTeacher = false

    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.loginStatusMessage = "Hata: \(error.localizedDescription)"
                    self.isLoggedIn = false
                }
                return
            }

            guard let uid = result?.user.uid else { return }
            self.checkUserRole(uid: uid)
            print("Kontrol edilen UID: \(uid)")
        }
    }

    private func checkUserRole(uid: String) {
        let db = Firestore.firestore()
        db.collection("ogretmenler").document(uid).getDocument { snapshot, error in
            DispatchQueue.main.async {
                self.isTeacher = snapshot?.exists == true
                self.isLoggedIn = true
            }
        }
    }
}
