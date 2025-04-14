import SwiftUI
import FirebaseFirestore

struct AdminSeansEkleView: View {
    @Environment(\.dismiss) var dismiss

    @State private var secilenTarih = Date()
    @State private var saat = ""
    @State private var secilenTur = "Birebir"
    @State private var ogrenciler: [(id: String, isim: String)] = []
    @State private var secilenOgrenciID = ""
    @State private var ayniGundekiSeanslar: [Seans] = []

    // 🔔 Uyarı için eklenen alanlar:
    @State private var gosterUyari = false
    @State private var uyariMesaji = ""
    @State private var devamEtOnayi = false

    let turler = ["Birebir", "Grup"]

    var body: some View {
        Form {
            Section(header: Text("Tarih")) {
                DatePicker("Seans Tarihi", selection: $secilenTarih, displayedComponents: .date)
                    .onChange(of: secilenTarih) { _ in
                        gunlukSeanslariYukle()
                    }
            }

            Section(header: Text("Saat")) {
                TextField("Örn: 14:00", text: $saat)
                    .keyboardType(.numbersAndPunctuation)
            }

            Section(header: Text("Tür")) {
                Picker("Seans Türü", selection: $secilenTur) {
                    ForEach(turler, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section(header: Text("Öğrenci")) {
                Picker("Öğrenci Seç", selection: $secilenOgrenciID) {
                    ForEach(ogrenciler, id: \.id) { ogrenci in
                        Text(ogrenci.isim).tag(ogrenci.id)
                    }
                }
            }

            if !ayniGundekiSeanslar.isEmpty {
                Section(header: Text("Bu Güne Ait Seanslar")) {
                    ForEach(ayniGundekiSeanslar, id: \.id) { seans in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("👶 \(seans.ogrenciIsmi)")
                            Text("🕒 \(seans.saat) • \(seans.tur)")
                        }
                    }
                }
            }

            Button("Seansı Kaydet") {
                seansiKaydet()
            }
            .disabled(secilenOgrenciID.isEmpty || saat.isEmpty)
        }
        .navigationTitle("Yeni Seans Ekle")
        .onAppear {
            ogrencileriYukle()
            gunlukSeanslariYukle()
        }
        .alert(uyariMesaji, isPresented: $gosterUyari) {
            Button("Vazgeç", role: .cancel) {}
            Button("Ekle", role: .destructive) {
                devamEtOnayi = true
                seansiKaydet()
            }
        }
    }

    private func ogrencileriYukle() {
        let db = Firestore.firestore()
        db.collection("ogrenciler").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { return }
            self.ogrenciler = docs.compactMap { doc in
                let data = doc.data()
                let isim = data["isim"] as? String ?? "Bilinmiyor"
                return (id: doc.documentID, isim: isim)
            }

            if let ilk = self.ogrenciler.first {
                self.secilenOgrenciID = ilk.id
            }
        }
    }

    private func gunlukSeanslariYukle() {
        let db = Firestore.firestore()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let seciliTarihString = formatter.string(from: secilenTarih)

        db.collection("seanslar").whereField("tarih", isEqualTo: seciliTarihString).getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { return }

            self.ayniGundekiSeanslar = docs.compactMap { doc in
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
                    ogrenciID: data["ogrenci_id"] as? String ?? ""
                )
            }
        }
    }

    private func seansiKaydet() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let tarihString = formatter.string(from: secilenTarih)

        let mevcutSeansVar = ayniGundekiSeanslar.contains { $0.saat == saat }

        if mevcutSeansVar && !devamEtOnayi {
            uyariMesaji = "Bu saatte zaten bir seans var. Yine de eklemek istiyor musun?"
            gosterUyari = true
            return
        }

        let ogrenciIsmi = ogrenciler.first(where: { $0.id == secilenOgrenciID })?.isim ?? "Bilinmiyor"

        let yeniSeans: [String: Any] = [
            "tarih": tarihString,
            "saat": saat,
            "ogrenci_id": secilenOgrenciID,
            "ogrenci_ismi": ogrenciIsmi,
            "tur": secilenTur,
            "durum": "bekliyor",
            "onaylandi": true
        ]

        let db = Firestore.firestore()
        db.collection("seanslar").addDocument(data: yeniSeans) { error in
            if error == nil {
                dismiss()
            }
        }
    }
}
