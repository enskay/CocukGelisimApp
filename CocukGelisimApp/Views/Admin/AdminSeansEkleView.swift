import SwiftUI
import FirebaseFirestore

struct AdminSeansEkleView: View {
    @Environment(\.dismiss) var dismiss
    @State private var secilenOgrenciID = ""
    @State private var secilenOgrenciIsmi = ""
    @State private var secilenOgretmenID = ""
    @State private var secilenOgretmenIsmi = ""
    @State private var tarih = Date()
    @State private var saat = ""
    @State private var tur = "Birebir"

    @State private var ogrenciler: [(id: String, isim: String)] = []
    @State private var ogretmenler: [(id: String, isim: String)] = []
    @State private var saatler: [String] = []

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Öğrenci")) {
                    Picker("Seç", selection: $secilenOgrenciID) {
                        ForEach(ogrenciler, id: \.id) { ogrenci in
                            Text(ogrenci.isim).tag(ogrenci.id)
                        }
                    }
                }

                Section(header: Text("Öğretmen")) {
                    Picker("Seç", selection: $secilenOgretmenID) {
                        ForEach(ogretmenler, id: \.id) { ogretmen in
                            Text(ogretmen.isim).tag(ogretmen.id)
                        }
                    }
                }

                Section(header: Text("Tarih")) {
                    DatePicker("Seç", selection: $tarih, displayedComponents: .date)
                }

                Section(header: Text("Saat")) {
                    Picker("Saat Seç", selection: $saat) {
                        ForEach(saatler, id: \.self) { s in
                            Text(s).tag(s)
                        }
                    }
                }

                Section(header: Text("Seans Türü")) {
                    Picker("Tür", selection: $tur) {
                        Text("Birebir").tag("Birebir")
                        Text("Grup").tag("Grup")
                    }
                    .pickerStyle(.segmented)
                }

                Button("Kaydet") {
                    seansEkle()
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Seans Ekle")
            .onAppear {
                saatleriOlustur()
                ogrencileriYukle()
                ogretmenleriYukle()
            }
        }
    }

    private func saatleriOlustur() {
        var saatler: [String] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        for hour in 9..<19 {
            for minute in stride(from: 0, to: 60, by: 15) {
                let date = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date())!
                saatler.append(formatter.string(from: date))
            }
        }
        self.saatler = saatler
    }

    private func ogrencileriYukle() {
        let db = Firestore.firestore()
        db.collection("ogrenciler").getDocuments { snap, _ in
            guard let docs = snap?.documents else { return }
            self.ogrenciler = docs.map { doc in
                let data = doc.data()
                let isim = data["isim"] as? String ?? "-"
                return (doc.documentID, isim)
            }
            if let first = self.ogrenciler.first {
                self.secilenOgrenciID = first.id
                self.secilenOgrenciIsmi = first.isim
            }
        }
    }

    private func ogretmenleriYukle() {
        let db = Firestore.firestore()
        db.collection("ogretmenler").getDocuments { snap, _ in
            guard let docs = snap?.documents else { return }
            self.ogretmenler = docs.map { doc in
                let data = doc.data()
                let isim = data["isim"] as? String ?? "-"
                return (doc.documentID, isim)
            }
            if let first = self.ogretmenler.first {
                self.secilenOgretmenID = first.id
                self.secilenOgretmenIsmi = first.isim
            }
        }
    }

    private func seansEkle() {
        let db = Firestore.firestore()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let veri: [String: Any] = [
            "ogrenci_id": secilenOgrenciID,
            "ogrenci_ismi": secilenOgrenciIsmi,
            "ogretmen_id": secilenOgretmenID,
            "ogretmen_ismi": secilenOgretmenIsmi,
            "tarih": formatter.string(from: tarih),
            "saat": saat,
            "tur": tur,
            "durum": "bekliyor",
            "onaylandi": true
        ]

        db.collection("seanslar").addDocument(data: veri) { err in
            if err == nil {
                dismiss()
            }
        }
    }
}
