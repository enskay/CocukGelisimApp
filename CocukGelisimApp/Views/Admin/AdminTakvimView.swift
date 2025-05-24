import SwiftUI
import FirebaseFirestore

struct AdminTakvimView: View {
    @State private var secilenTarih = Date()
    @State private var gunlukSeanslar: [Seans] = []
    @State private var secilenOgretmen = "Tümü"

    let ogretmenler = ["Tümü", "Alper", "Elif"]
    let ogretmenIDler = [
        "Alper": "ZZ3PM4pTkEefhmcm6JB4BXsltgu2",
        "Elif": "TVLwEsZhJuUUQrUpRSKk1jiufBv2"
    ]

    var body: some View {
        VStack(spacing: 16) {
            DatePicker("Tarih Seç", selection: $secilenTarih, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding(.horizontal)

            Picker("Öğretmen Seç", selection: $secilenOgretmen) {
                ForEach(ogretmenler, id: \.self) { ogretmen in
                    Text(ogretmen).tag(ogretmen)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            Divider()

            Text("📅 \(formattedTarih(secilenTarih)) Seansları")
                .font(.title3)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            if gunlukSeanslar.isEmpty {
                VStack {
                    Spacer(minLength: 50)
                    Text("Bu kriterlere uygun seans bulunamadı.")
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                }
            } else {
                List(gunlukSeanslar) { seans in
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
                    .padding(.vertical, 6)
                }
                .listStyle(PlainListStyle())
            }
        }
        .padding(.top)
        .onAppear {
            seanslariGetir()
        }
        .onChange(of: secilenTarih) { _ in
            seanslariGetir()
        }
        .onChange(of: secilenOgretmen) { _ in
            seanslariGetir()
        }
        .navigationTitle("Takvim")
    }

    private func formattedTarih(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "dd MMMM yyyy, EEEE"
        return formatter.string(from: date)
    }

    private func seanslariGetir() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let secilenStr = formatter.string(from: secilenTarih)

        var sorgu = Firestore.firestore().collection("seanslar")
            .whereField("tarih", isEqualTo: secilenStr)

        if let secilenID = ogretmenIDler[secilenOgretmen] {
            sorgu = sorgu.whereField("ogretmen_id", isEqualTo: secilenID)
        }

        sorgu.getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else {
                self.gunlukSeanslar = []
                return
            }

            self.gunlukSeanslar = docs.compactMap { doc in
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
                    ogretmenIsmi: d["ogretmen_ismi"] as? String ?? "-"
                )
            }
        }
    }
}
