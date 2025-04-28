import SwiftUI
import FirebaseFirestore

struct AdminSeansListView: View {
    @State private var groupedSeanslar: [String: [Seans]] = [:]
    @State private var sortedTarihListesi: [String] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(sortedTarihListesi, id: \.self) { tarih in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(formattedDateString(tarih))
                            .font(.title3)
                            .bold()
                            .padding(.leading)

                        ForEach(groupedSeanslar[tarih] ?? []) { seans in
                            VStack(alignment: .leading, spacing: 6) {
                                Text("👶 Öğrenci: \(seans.ogrenciIsmi)")
                                    .font(.headline)
                                Text("🕒 Saat: \(seans.saat)")
                                    .font(.subheadline)
                                Text("👥 Tür: \(seans.tur)")
                                    .font(.subheadline)
                                Text("📌 Durum: \(seans.durum.capitalized)")
                                    .font(.subheadline)
                            }
                            .padding()
                            .background(
                                seans.tur.lowercased() == "grup"
                                ? Color.blue.opacity(0.15)
                                : Color.green.opacity(0.15)
                            )
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 12)
                }
            }
            .padding(.top)
        }
        .navigationTitle("Tüm Seanslar")
        .onAppear {
            seanslariYukle()
        }
    }

    private func seanslariYukle() {
        let db = Firestore.firestore()

        db.collection("seanslar")
            .order(by: "tarih")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else { return }

                var seansListesi: [Seans] = documents.compactMap { doc in
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

                // 🔥 Tarihe göre grupla
                var tempGrouped: [String: [Seans]] = [:]
                for seans in seansListesi {
                    tempGrouped[seans.tarih, default: []].append(seans)
                }

                // 🔥 Tarihleri sıralı liste yap
                let sortedTarih = tempGrouped.keys.sorted()

                DispatchQueue.main.async {
                    self.groupedSeanslar = tempGrouped
                    self.sortedTarihListesi = sortedTarih
                }
            }
    }

    private func formattedDateString(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.locale = Locale(identifier: "tr_TR")
            displayFormatter.dateFormat = "dd MMMM yyyy, EEEE"
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}
