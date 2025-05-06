import SwiftUI
import FirebaseFirestore

struct AdminOgrencilerView: View {
    @State private var ogrenciler: [OgrenciVeliBilgisi] = []
    @State private var loading = true

    var body: some View {
        VStack {
            if loading {
                ProgressView("Yükleniyor...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.5)
            } else {
                List(ogrenciler) { ogrenci in
                    NavigationLink(destination: OgrenciDetayView(ogrenciID: ogrenci.ogrenciID)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("👶 Öğrenci: \(ogrenci.ogrenciIsmi)")
                                .font(.headline)
                            Text("🎂 Yaş: \(ogrenci.yas) Ay")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("👩‍👧‍👦 Veli: \(ogrenci.veliIsmi)")
                                .font(.subheadline)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                    }
                }
                .listStyle(.plain)
                .background(Color(.systemGroupedBackground))
            }
        }
        .navigationTitle("Öğrenciler")
        .onAppear {
            ogrencileriYukle()
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
                    let dogumTarihi = (ogrData?["dogumTarihi"] as? Timestamp)?.dateValue() ?? Date()
                    let yasAy = ayFarkiHesapla(dogumTarihi: dogumTarihi)

                    let model = OgrenciVeliBilgisi(
                        id: doc.documentID,
                        ogrenciID: ogrenciID,
                        veliIsmi: veliIsmi,
                        email: "-", // Şu an mail verimiz yok
                        ogrenciIsmi: ogrenciIsmi,
                        yas: yasAy
                    )
                    tempListe.append(model)
                }
            }

            group.notify(queue: .main) {
                self.ogrenciler = tempListe
                self.loading = false
            }
        }
    }

    private func ayFarkiHesapla(dogumTarihi: Date) -> Int {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: dogumTarihi, to: now)
        return components.month ?? 0
    }
}
