import SwiftUI
import FirebaseFirestore

struct VeliSeanslarimView: View {
    @EnvironmentObject var loginVM: LoginViewModel

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
            Text("👩‍🏫 Öğretmen: \(seans.ogretmenIsmi)")
        }
        .padding()
        .background(Color.orange.opacity(0.15))
        .cornerRadius(14)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 2, y: 2)
        .padding(.horizontal)
    }

    private func seanslariYukle() {
        guard let veliID = loginVM.currentVeliID else {
            print("🔥 Giriş yapan veli ID'si bulunamadı")
            return
        }

        let db = Firestore.firestore()
        db.collection("veliler").document(veliID).getDocument { docSnap, _ in
            guard let data = docSnap?.data(),
                  let ogrenciID = data["ogrenci_id"] as? String else {
                print("🔥 Öğrenci ID alınamadı")
                return
            }

            db.collection("seanslar")
                .whereField("ogrenci_id", isEqualTo: ogrenciID)
                .getDocuments { snap, error in
                    guard let docs = snap?.documents else {
                        print("🔥 Seanslar getirilemedi")
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
                            ogretmenID: d["ogretmen_id"] as? String ?? "",
                            ogretmenIsmi: d["ogretmen_ismi"] as? String ?? "Öğretmen"
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
