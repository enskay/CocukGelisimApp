import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct VeliSeanslarimView: View {
    @State private var grupSeanslar: [String: [Seans]] = [:]
    @State private var birebirSeanslar: [String: [Seans]] = [:]
    @State private var tarihListesi: [String] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if !grupSeanslar.isEmpty {
                    Text("👥 Grup Seansları")
                        .font(.title2.bold())
                        .padding(.horizontal)

                    ForEach(tarihListesi, id: \.self) { tarih in
                        if let seanslar = grupSeanslar[tarih], !seanslar.isEmpty {
                            Text(tarih)
                                .font(.headline)
                                .padding(.leading)

                            ForEach(seanslar) { seans in
                                seansKart(seans: seans)
                            }
                        }
                    }
                }

                if !birebirSeanslar.isEmpty {
                    Text("🧑‍🤝‍🧑 Birebir Seanslar")
                        .font(.title2.bold())
                        .padding(.horizontal)

                    ForEach(tarihListesi, id: \.self) { tarih in
                        if let seanslar = birebirSeanslar[tarih], !seanslar.isEmpty {
                            Text(tarih)
                                .font(.headline)
                                .padding(.leading)

                            ForEach(seanslar) { seans in
                                seansKart(seans: seans)
                            }
                        }
                    }
                }

                if grupSeanslar.isEmpty && birebirSeanslar.isEmpty {
                    Text("Henüz seans bulunmuyor.")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .padding(.top)
        }
        .navigationTitle("Seanslarım")
        .onAppear {
            seanslariYukle()
        }
    }

    private func seansKart(seans: Seans) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🕒 Saat: \(seans.saat)")
            Text("📌 Durum: \(seans.durum.capitalized)")
            if let neden = seans.neden, !neden.isEmpty {
                Text("📝 Not: \(neden)")
                    .foregroundColor(.gray)
            }

            NavigationLink("Ayrıntılar", destination: VeliSeansDetayView(seans: seans))
                .font(.caption)
                .padding(.top, 4)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 3)
        .padding(.horizontal)
    }

    private func seanslariYukle() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("🔥 Kullanıcı UID bulunamadı")
            return
        }

        let db = Firestore.firestore()
        db.collection("veliler").document(uid).getDocument { docSnap, _ in
            guard let data = docSnap?.data(),
                  let ogrenciID = data["ogrenci_id"] as? String else {
                print("🔥 Veli belgesi bulunamadı veya öğrenci_id eksik")
                return
            }

            db.collection("seanslar")
                .whereField("ogrenci_id", isEqualTo: ogrenciID)
                .getDocuments { snap, error in
                    guard let docs = snap?.documents else {
                        print("🔥 Seanslar yüklenemedi")
                        return
                    }

                    var grup: [String: [Seans]] = [:]
                    var birebir: [String: [Seans]] = [:]
                    var tumTarihler: Set<String> = []

                    for doc in docs {
                        let d = doc.data()
                        let tarihStr = d["tarih"] as? String ?? "-"
                        let displayTarih = tarihGosterimi(tarihStr)

                        let seans = Seans(
                            id: doc.documentID,
                            ogrenciIsmi: d["ogrenci_ismi"] as? String ?? "-",
                            tarih: tarihStr,
                            saat: d["saat"] as? String ?? "--:--",
                            tur: d["tur"] as? String ?? "-",
                            durum: d["durum"] as? String ?? "bekliyor",
                            onaylandi: d["onaylandi"] as? Bool ?? false,
                            neden: d["neden"] as? String,
                            ogrenciID: d["ogrenci_id"] as? String ?? "",
                            ogretmenID: d["ogretmen_id"] as? String ?? ""
                        )

                        tumTarihler.insert(displayTarih)

                        if seans.tur.lowercased() == "grup" {
                            grup[displayTarih, default: []].append(seans)
                        } else {
                            birebir[displayTarih, default: []].append(seans)
                        }
                    }

                    self.grupSeanslar = grup
                    self.birebirSeanslar = birebir
                    self.tarihListesi = tumTarihler.sorted()
                }
        }
    }

    private func tarihGosterimi(_ tarihStr: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"

        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "tr_TR")
        displayFormatter.dateFormat = "dd MMMM yyyy, EEEE"

        if let date = inputFormatter.date(from: tarihStr) {
            return displayFormatter.string(from: date)
        }
        return tarihStr
    }
}
