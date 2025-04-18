import SwiftUI
import FirebaseFirestore

struct AdminSeansListView: View {
    @State private var seanslar: [Seans] = []

    var body: some View {
        NavigationStack {
            List {
                ForEach(seanslar) { seans in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("👶 Öğrenci: \(seans.ogrenciIsmi)")
                        Text("📅 Tarih: \(seans.tarih)")
                        Text("🕒 Saat: \(seans.saat)")
                        Text("👥 Tür: \(seans.tur)")
                        Text("📌 Durum: \(seans.durum.capitalized)")
                        
                        if let neden = seans.neden, !neden.isEmpty {
                            Text("📝 Neden: \(neden)")
                                .foregroundColor(.gray)
                        }

                        HStack {
                            Button("Katıldı") {
                                seansDurumuGuncelle(seansID: seans.id, yeniDurum: "katıldı", ogrenciID: seans.ogrenciID)
                            }
                            Button("Ertelendi") {
                                seansDurumuGuncelle(seansID: seans.id, yeniDurum: "ertelendi", ogrenciID: seans.ogrenciID)
                            }
                            Button("Gelmedi") {
                                seansDurumuGuncelle(seansID: seans.id, yeniDurum: "gelmedi", ogrenciID: seans.ogrenciID)
                            }
                            Button(role: .destructive) {
                                seansiSil(seansID: seans.id)
                            } label: {
                                Text("Sil")
                            }
                        }
                        .buttonStyle(.bordered)
                        .font(.caption)
                        .padding(.top, 6)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Tüm Seanslar")
            .onAppear {
                seanslariYukle()
            }
        }
    }

    private func tarihStr(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func seanslariYukle() {
        let db = Firestore.firestore()
        db.collection("seanslar").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { return }

            self.seanslar = docs.compactMap { doc in
                let data = doc.data()
                return Seans(
                    id: doc.documentID,
                    ogrenciIsmi: data["ogrenci_ismi"] as? String ?? "-",
                    tarih: data["tarih"] as? String ?? "-",
                    saat: data["saat"] as? String ?? "--:--",
                    tur: data["tur"] as? String ?? "-",
                    durum: data["durum"] as? String ?? "bekliyor",
                    onaylandi: data["onaylandi"] as? Bool ?? false,
                    neden: data["neden"] as? String,
                    ogrenciID: data["ogrenci_id"] as? String ?? "",
                    ogretmenID: data["ogretmen_id"] as? String ?? ""
                )
            }
        }
    }

    private func seansDurumuGuncelle(seansID: String, yeniDurum: String, ogrenciID: String) {
        let db = Firestore.firestore()
        db.collection("seanslar").document(seansID).updateData([
            "durum": yeniDurum
        ])
    }

    private func seansiSil(seansID: String) {
        let db = Firestore.firestore()
        db.collection("seanslar").document(seansID).delete { error in
            if error == nil {
                seanslar.removeAll { $0.id == seansID }
            }
        }
    }
}
