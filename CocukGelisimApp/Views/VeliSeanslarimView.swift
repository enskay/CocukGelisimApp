import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct VeliSeanslarimView: View {
    @State private var seanslar: [Seans] = []

    var body: some View {
        NavigationStack {
            List(seanslar) { seans in
                NavigationLink(destination: VeliSeansDetayView(seans: seans)) {
                    VStack(alignment: .leading) {
                        Text("📅 \(seans.tarih)  ⏰ \(seans.saat)")
                        Text("👥 Tür: \(seans.tur)")
                            .font(.subheadline)
                        Text("📌 Durum: \(seans.durum.capitalized)")
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Seanslarım")
            .onAppear {
                seanslariYukle()
            }
        }
    }

    private func seanslariYukle() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("veliler").document(uid).getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  let ogrenciID = data["ogrenci_id"] as? String else { return }

            db.collection("seanslar")
                .whereField("ogrenci_id", isEqualTo: ogrenciID)
                .getDocuments { snapshot, error in
                    guard let docs = snapshot?.documents else { return }

                    self.seanslar = docs.map { doc in
                        let d = doc.data()
                        return Seans(
                            id: doc.documentID,
                            ogrenciIsmi: d["ogrenci_ismi"] as? String ?? "-",
                            tarih: d["tarih"] as? String ?? "-",
                            saat: d["saat"] as? String ?? "--:--",
                            tur: d["tur"] as? String ?? "-",
                            durum: d["durum"] as? String ?? "bekliyor",
                            onaylandi: d["onaylandi"] as? Bool ?? false,
                            neden: d["neden"] as? String,
                            ogrenciID: d["ogrenci_id"] as? String ?? "",
                            ogretmenID: d["ogretmen_id"] as? String ?? ""
                        )
                    }
                }
        }
    }
}
