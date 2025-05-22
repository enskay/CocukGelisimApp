import SwiftUI
import FirebaseFirestore

struct AdminSeansListView: View {
    @State private var groupedSeanslar: [String: [Seans]] = [:]
    @State private var sortedTarihListesi: [String] = []
    @State private var loading = true

    let ogretmenIsimleri = [
        "ZZ3PM4pTkEefhmcm6JB4BXsltgu2": "Alper",
        "TVLwEsZhJuUUQrUpRSKk1jiufBv2": "Elif"
    ]

    var body: some View {
        VStack {
            if loading {
                ProgressView("Yükleniyor...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.5)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(sortedTarihListesi, id: \.self) { tarih in
                            VStack(alignment: .leading, spacing: 12) {
                                Text(formattedDateString(tarih))
                                    .font(.title3)
                                    .bold()
                                    .padding(.leading, 16)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                ForEach(groupedSeanslar[tarih] ?? []) { seans in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("👶 Öğrenci: \(seans.ogrenciIsmi)")
                                            .font(.headline)
                                        Text("🕒 Saat: \(seans.saat)")
                                        Text("👥 Tür: \(seans.tur)")
                                        Text("📌 Durum: \(seans.durum.capitalized)")
                                        Text("👨‍🏫 Öğretmen: \(ogretmenIsimleri[seans.ogretmenID] ?? "Bilinmiyor")")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .background(
                                        seans.tur.lowercased() == "grup"
                                        ? Color.blue.opacity(0.15)
                                        : Color.green.opacity(0.15)
                                    )
                                    .cornerRadius(12)
                                    .shadow(radius: 3)
                                    .padding(.horizontal, 16)
                                    .transition(.move(edge: .trailing))
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
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
                        ogretmenID: d["ogretmen_id"] as? String ?? "",
                        ogretmenIsmi: d["ogretmen_ismi"] as? String ?? "-" // ✅ bunu ekle

                    )
                }

                var tempGrouped: [String: [Seans]] = [:]
                for seans in seansListesi {
                    tempGrouped[seans.tarih, default: []].append(seans)
                }

                let sortedTarih = tempGrouped.keys.sorted()

                DispatchQueue.main.async {
                    self.groupedSeanslar = tempGrouped
                    self.sortedTarihListesi = sortedTarih
                    self.loading = false
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
