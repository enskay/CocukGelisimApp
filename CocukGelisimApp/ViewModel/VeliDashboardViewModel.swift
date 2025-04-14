


import Foundation
import FirebaseAuth
import FirebaseFirestore

class VeliDashboardViewModel: ObservableObject {
    
    @Published var veliAdi: String = ""
    @Published var ogrenciIsmi: String = ""
    @Published var ogrenciYas: Int = 0
    
    func fetchVeliVeOgrenciBilgileri() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("veliler").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                self.veliAdi = data["veliAdi"] as? String ?? ""
                let ogrenciID = data["ogrenci_id"] as? String ?? ""
                
                db.collection("ogrenciler").document(ogrenciID).getDocument { studentSnap, error in
                    if let ogrenciData = studentSnap?.data() {
                        self.ogrenciIsmi = ogrenciData["isim"] as? String ?? ""
                        self.ogrenciYas = ogrenciData["yas"] as? Int ?? 0
                    }
                }
            }
        }
    }
}
