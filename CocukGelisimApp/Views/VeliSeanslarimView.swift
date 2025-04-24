import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct VeliSeanslarimView: View {
    @State private var grupSeanslar: [String: [Seans]] = [:]
    @State private var birebirSeanslar: [String: [Seans]] = [:]
    @State private var kalanErteleme: Int = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("🎯 Kalan Grup Seans Erteleme Hakkı: \(kalanErteleme)")
                    .bold()

                Text("👥 Grup Seansları").font(.title3).bold()
                ForEach(grupSeanslar.keys.sorted(), id: \.self) { tarih in
                    Text("📅 \(tarih)").font(.headline)
                    ForEach(grupSeanslar[tarih] ?? []) { seans in
                        seansCard(seans)
                    }
                }

                Text("🤝 Birebir Seanslar").font(.title3).bold()
                ForEach(birebirSeanslar.keys.sorted(), id: \.self) { tarih in
                    Text("📅 \(tarih)").font(.headline)
                    ForEach(birebirSeanslar[tarih] ?? []) { seans in
                        seansCard(seans)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Seanslarım")
        .onAppear {
            yukle()
        }
    }

    @ViewBuilder
    func seansCard(_ seans: Seans) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("🕒 Saat: \(seans.saat)")
            Text("📌 Durum: \(seans.durum.capitalized)")

            if let neden = seans.neden, !neden.isEmpty {
                Text("📝 Neden: \(neden)").foregroundColor(.gray)
            }

            if seans.durum != "gelmedi" {
                Button("❌ Seansı İptal Et") {
                    if seans.tur == "Grup" {
                        if kalanErteleme > 0 {
                            iptalEt(seans: seans)
                        } else {
                            // Uyarı: hak kalmadı
                            print("Erteleme hakkınız kalmadı.")
                        }
                    } else {
                        iptalEt(seans: seans) // Birebir → sınırsız
                    }
                }
                .buttonStyle(.bordered)
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }

    private func iptalEt(seans: Seans) {
        let db = Firestore.firestore()
        var yeniErteleme = kalanErteleme

        if seans.tur == "Grup" && kalanErteleme > 0 {
            yeniErteleme -= 1
        }

        // Seans güncelle
        db.collection("seanslar").document(seans.id).updateData([
            "durum": "iptal"
        ])

        // Öğrenci güncelle
        db.collection("ogrenciler").document(seans.ogrenciID).updateData([
            "kalan_erteleme": yeniErteleme
        ])

        DispatchQueue.main.async {
            kalanErteleme = yeniErteleme
            yukle()
        }
    }

    private func yukle() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("veliler").document(uid).getDocument { veliDoc, error in
            guard let data = veliDoc?.data(),
                  let ogrenciID = data["ogrenci_id"] as? String else { return }

            // Öğrenci erteleme hak
            db.collection("ogrenciler").document(ogrenciID).getDocument { snap, _ in
                if let d = snap?.data() {
                    self.kalanErteleme = d["kalan_erteleme"] as? Int ?? 0
                }
            }

            // Seansları çek
            db.collection("seanslar")
                .whereField("ogrenci_id", isEqualTo: ogrenciID)
                .getDocuments { snapshot, error in
                    guard let docs = snapshot?.documents else { return }

                    var grupDict: [String: [Seans]] = [:]
                    var birebirDict: [String: [Seans]] = [:]

                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "tr_TR")
                    formatter.dateFormat = "yyyy-MM-dd"

                    let displayFormatter = DateFormatter()
                    displayFormatter.locale = Locale(identifier: "tr_TR")
                    displayFormatter.dateFormat = "dd MMMM EEEE"

                    for doc in docs {
                        let d = doc.data()
                        var tarihKey = "-"
                        if let t = d["tarih"] as? String {
                            tarihKey = t
                        } else if let t = d["tarih"] as? Timestamp {
                            tarihKey = formatter.string(from: t.dateValue())
                        }

                        var displayDate = tarihKey
                        if let date = formatter.date(from: tarihKey) {
                            displayDate = displayFormatter.string(from: date)
                        }

                        let seans = Seans(
                            id: doc.documentID,
                            ogrenciIsmi: d["ogrenci_ismi"] as? String ?? "-",
                            tarih: tarihKey,
                            saat: d["saat"] as? String ?? "--:--",
                            tur: d["tur"] as? String ?? "-",
                            durum: d["durum"] as? String ?? "bekliyor",
                            onaylandi: d["onaylandi"] as? Bool ?? false,
                            neden: d["neden"] as? String,
                            ogrenciID: ogrenciID,
                            ogretmenID: d["ogretmen_id"] as? String ?? ""
                        )

                        if seans.tur == "Grup" {
                            grupDict[displayDate, default: []].append(seans)
                        } else {
                            birebirDict[displayDate, default: []].append(seans)
                        }
                    }

                    DispatchQueue.main.async {
                        self.grupSeanslar = grupDict
                        self.birebirSeanslar = birebirDict
                    }
                }
        }
    }
}
