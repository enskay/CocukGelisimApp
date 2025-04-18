import SwiftUI
import FirebaseFirestore

struct AdminSeansEkleView: View {
    @Environment(\.dismiss) var dismiss

    @State private var secilenTarih = Date()
    @State private var secilenSaat = ""
    @State private var secilenOgrenciID = ""
    @State private var secilenOgretmenID = ""
    @State private var seansTuru = "Birebir"
    @State private var mevcutSeanslar: [Seans] = []
    @State private var ogrenciler: [(id: String, isim: String)] = []
    @State private var ogretmenler: [(id: String, isim: String)] = []
    @State private var gorsunUyari = false

    let saatler = ["09:00", "10:00", "11:00", "13:00", "14:00", "15:00"]

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Tarih", selection: $secilenTarih, displayedComponents: .date)
                    .onChange(of: secilenTarih) { _ in
                        mevcutSeanslariGetir()
                    }

                Picker("Saat", selection: $secilenSaat) {
                    ForEach(saatler, id: \.self) { Text($0) }
                }

                Picker("Seans Türü", selection: $seansTuru) {
                    Text("Birebir").tag("Birebir")
                    Text("Grup").tag("Grup")
                }

                Picker("Öğretmen Seç", selection: $secilenOgretmenID) {
                    ForEach(ogretmenler, id: \.id) { ogretmen in
                        Text(ogretmen.isim).tag(ogretmen.id)
                    }
                }

                Picker("Öğrenci Seç", selection: $secilenOgrenciID) {
                    ForEach(ogrenciler, id: \.id) { ogrenci in
                        Text(ogrenci.isim).tag(ogrenci.id)
                    }
                }

                if !mevcutSeanslar.isEmpty {
                    Section(header: Text("Bu Günkü Mevcut Seanslar")) {
                        ForEach(mevcutSeanslar) { seans in
                            Text("\(seans.saat) - \(seans.ogrenciIsmi) (\(seans.tur))")
                        }
                    }
                }

                Button("Seansı Kaydet") {
                    if seansTuru == "Birebir" && mevcutSeanslar.contains(where: {
                        $0.saat == secilenSaat && $0.ogretmenID == secilenOgretmenID
                    }) {
                        gorsunUyari = true
                    } else {
                        seansiKaydet()
                    }
                }
                .alert("Bu saatte bu öğretmen için birebir seans zaten var. Yine de eklemek istiyor musunuz?", isPresented: $gorsunUyari) {
                    Button("İptal", role: .cancel) {}
                    Button("Ekle", role: .destructive) {
                        seansiKaydet()
                    }
                }

                Button("⬅️ Geri Dön") {
                    dismiss()
                }
                .foregroundColor(.blue)
            }
            .navigationTitle("Seans Ekle")
            .onAppear {
                ogrencileriYukle()
                ogretmenleriYukle()
                mevcutSeanslariGetir()
            }
        }
    }

    private func tarihStr() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: secilenTarih)
    }

    private func mevcutSeanslariGetir() {
        let db = Firestore.firestore()
        guard !secilenOgretmenID.isEmpty else { return }
        db.collection("seanslar")
            .whereField("tarih", isEqualTo: tarihStr())
            .whereField("ogretmen_id", isEqualTo: secilenOgretmenID)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else { return }

                self.mevcutSeanslar = docs.compactMap { doc in
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

    private func ogrencileriYukle() {
        let db = Firestore.firestore()
        db.collection("ogrenciler").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { return }
            self.ogrenciler = docs.map { doc in
                let data = doc.data()
                let isim = data["isim"] as? String ?? "-"
                return (doc.documentID, isim)
            }
            if let first = self.ogrenciler.first {
                self.secilenOgrenciID = first.id
            }
        }
    }

    private func ogretmenleriYukle() {
        let db = Firestore.firestore()
        db.collection("ogretmenler").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { return }
            self.ogretmenler = docs.map { doc in
                let data = doc.data()
                let isim = data["isim"] as? String ?? "-"
                return (doc.documentID, isim)
            }
            if let first = self.ogretmenler.first {
                self.secilenOgretmenID = first.id
            }
        }
    }

    private func seansiKaydet() {
        let db = Firestore.firestore()
        db.collection("seanslar").addDocument(data: [
            "tarih": tarihStr(),
            "saat": secilenSaat,
            "ogrenci_id": secilenOgrenciID,
            "ogrenci_ismi": ogrenciler.first(where: { $0.id == secilenOgrenciID })?.isim ?? "-",
            "tur": seansTuru,
            "durum": "bekliyor",
            "onaylandi": true,
            "ogretmen_id": secilenOgretmenID
        ])
        dismiss()
    }
}
