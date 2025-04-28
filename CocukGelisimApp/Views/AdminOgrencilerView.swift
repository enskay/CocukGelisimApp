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
                        Text("🎂 Yaş: \(ogrenci.yas) ay")
                        Text("👩‍👧‍👦 Veli: \(ogrenci.veliIsmi)")
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

                group.enter()

                db.collection("ogrenciler").document(ogrenciID).getDocument { ogrenciDoc, _ in
                    defer { group.leave() }

                    let ogrData = ogrenciDoc?.data()
                    let ogrenciIsmi = ogrData?["isim"] as? String ?? "-"
                    
                    // 🔥 Artık doğum tarihinden ay farkı hesaplıyoruz
                    let dogumTarihi = (ogrData?["dogumTarihi"] as? Timestamp)?.dateValue() ?? Date()
                    let yasAy = ayFarkiHesapla(dogumTarihi: dogumTarihi)

                    let model = OgrenciVeliBilgisi(
                        id: doc.documentID,
                        ogrenciID: ogrenciID,
                        veliIsmi: veliIsmi,
                        email: "-", // Mail verimiz yok
                        ogrenciIsmi: ogrenciIsmi,
                        yas: yasAy
                    )
                    tempListe.append(model)
                }
            }

            group.notify(queue: .main) {
                self.ogrenciler = tempListe
            }
        }
    }

    // 🔥 Doğum tarihinden ay farkı hesaplayan fonksiyon
    private func ayFarkiHesapla(dogumTarihi: Date) -> Int {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: dogumTarihi, to: now)
        return components.month ?? 0
    }
}
