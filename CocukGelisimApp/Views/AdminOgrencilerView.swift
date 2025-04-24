import SwiftUI
import FirebaseFirestore

struct AdminOgrencilerView: View {
    @State private var ogrenciler: [OgrenciVeliBilgisi] = []

    var body: some View {
        NavigationStack {
            List(ogrenciler) { ogrenci in
                NavigationLink(destination: OgrenciDetayView(ogrenciID: ogrenci.ogrenciID)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("👶 Öğrenci: \(ogrenci.ogrenciIsmi)")
                        Text("🎂 Yaş: \(ogrenci.yas)")
                        Text("👩‍👧‍👦 Veli: \(ogrenci.veliIsmi)")
                        Text("📧 E-posta: \(ogrenci.email)")
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Öğrenciler")
            .onAppear {
                ogrencileriYukle()
            }
        }
    }

    private func ogrencileriYukle() {
        let db = Firestore.firestore()
        db.collection("veliler").getDocuments { snap, error in
            guard let docs = snap?.documents else { return }

            var tempListe: [OgrenciVeliBilgisi] = []

            let group = DispatchGroup()

            for doc in docs {
                let veliData = doc.data()
                let ogrenciID = veliData["ogrenci_id"] as? String ?? ""
                let veliIsmi = veliData["veliAdi"] as? String ?? "-"
                let email = veliData["email"] as? String ?? "-"

                group.enter()

                db.collection("ogrenciler").document(ogrenciID).getDocument { ogrenciDoc, _ in
                    defer { group.leave() }

                    let ogrData = ogrenciDoc?.data()
                    let ogrenciIsmi = ogrData?["isim"] as? String ?? "-"
                    let yas = ogrData?["yas"] as? Int ?? 0

                    let model = OgrenciVeliBilgisi(
                        id: doc.documentID,
                        ogrenciID: ogrenciID,
                        veliIsmi: veliIsmi,
                        email: email,
                        ogrenciIsmi: ogrenciIsmi,
                        yas: yas
                    )
                    tempListe.append(model)
                }
            }

            group.notify(queue: .main) {
                self.ogrenciler = tempListe
            }
        }
    }
}
