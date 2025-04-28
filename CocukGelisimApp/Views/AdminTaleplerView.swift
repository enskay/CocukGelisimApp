import SwiftUI
import FirebaseFirestore



struct AdminTaleplerView: View {
    @State private var talepler: [SeansTalebi] = []
    @State private var aramaMetni: String = ""

    var body: some View {
        VStack {
            TextField("Öğrenci adına göre ara...", text: $aramaMetni)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            List {
                ForEach(talepler.filter {
                    aramaMetni.isEmpty || $0.ogrenciIsmi.lowercased().contains(aramaMetni.lowercased())
                }) { talep in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("👶 Öğrenci: \(talep.ogrenciIsmi)")
                        Text("📅 Tarih: \(talep.tarih)")
                        if !talep.neden.isEmpty {
                            Text("📝 Neden: \(talep.neden)").foregroundColor(.gray)
                        }

                        HStack {
                            Button("✅ Onayla") {
                                seansaCevir(talep: talep)
                            }
                            .buttonStyle(.borderedProminent)

                            Button("❌ Sil") {
                                talebiSil(talep: talep)
                            }
                            .buttonStyle(.bordered)
                            .foregroundColor(.red)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .navigationTitle("Seans Talepleri")
        .onAppear {
            talepleriYukle()
        }
    }

    private func talepleriYukle() {
        let db = Firestore.firestore()
        db.collection("seans_talepleri").getDocuments { snap, error in
            guard let docs = snap?.documents else { return }

            self.talepler = docs.compactMap { doc in
                let d = doc.data()
                return SeansTalebi(
                    id: doc.documentID,
                    ogrenciID: d["ogrenci_id"] as? String ?? "",
                    ogrenciIsmi: d["ogrenci_ismi"] as? String ?? "-",
                    tarih: d["tarih"] as? String ?? "-",
                    neden: d["neden"] as? String ?? ""
                )
            }
        }
    }

    private func seansaCevir(talep: SeansTalebi) {
        let db = Firestore.firestore()

        let yeniSeans: [String: Any] = [
            "tarih": talep.tarih,
            "saat": "Belirlenmedi",
            "ogrenci_id": talep.ogrenciID,
            "ogrenci_ismi": talep.ogrenciIsmi,
            "tur": "Birebir",
            "durum": "bekliyor",
            "onaylandi": true
        ]

        db.collection("seanslar").addDocument(data: yeniSeans) { error in
            if error == nil {
                talebiSil(talep: talep)
            }
        }
    }

    private func talebiSil(talep: SeansTalebi) {
        let db = Firestore.firestore()
        db.collection("seans_talepleri").document(talep.id).delete { _ in
            talepler.removeAll { $0.id == talep.id }
        }
    }
}
