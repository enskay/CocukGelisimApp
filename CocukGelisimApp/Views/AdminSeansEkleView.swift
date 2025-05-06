import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AdminSeansEkleView: View {
    @State private var secilenOgrenciID = ""
    @State private var secilenTarih = Date()
    @State private var secilenSaat = ""
    @State private var secilenTur = "Birebir"
    @State private var ogretmenID = ""
    @State private var ogrenciler: [Ogrenci] = []
    @State private var saatler: [String] = []

    var body: some View {
        Form {
            Picker("Öğrenci", selection: $secilenOgrenciID) {
                ForEach(ogrenciler) { ogrenci in
                    Text(ogrenci.isim).tag(ogrenci.id)
                }
            }

            DatePicker("Tarih", selection: $secilenTarih, displayedComponents: .date)

            Picker("Saat", selection: $secilenSaat) {
                ForEach(saatler, id: \.self) { saat in
                    Text(saat).tag(saat)
                }
            }

            Picker("Tür", selection: $secilenTur) {
                Text("Birebir").tag("Birebir")
                Text("Grup").tag("Grup")
            }
            .pickerStyle(SegmentedPickerStyle())

            Button("Seansı Kaydet") {
                seansiKaydet()
                
            }
            .disabled(!formGecerliMi())
            
        }
        .navigationTitle("Seans Ekle")
        .onAppear {
            ogrencileriYukle()
            saatler = saatSecenekleriniOlustur()
            if let first = self.ogrenciler.first {
                self.secilenOgrenciID = first.id
            }
            if let uid = Auth.auth().currentUser?.uid {
                self.ogretmenID = uid
            }
        }
    }

    private func formGecerliMi() -> Bool {
        return !secilenOgrenciID.isEmpty && !secilenSaat.isEmpty && secilenTarih >= Calendar.current.startOfDay(for: Date())
    }

    private func saatSecenekleriniOlustur() -> [String] {
        var saatler: [String] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"

        let calendar = Calendar.current
        var current = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
        let end = calendar.date(bySettingHour: 19, minute: 0, second: 0, of: Date())!

        while current <= end {
            saatler.append(dateFormatter.string(from: current))
            current = calendar.date(byAdding: .minute, value: 15, to: current)!
        }

        return saatler
    }

    private func ogrencileriYukle() {
        let db = Firestore.firestore()
        db.collection("ogrenciler").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { return }

            self.ogrenciler = docs.map { doc in
                let data = doc.data()
                return Ogrenci(
                    id: doc.documentID,
                    isim: data["isim"] as? String ?? "-"
                )
            }
        }
    }

    private func seansiKaydet() {
        let db = Firestore.firestore()

        let secilenOgrenci = ogrenciler.first { $0.id == secilenOgrenciID }
        let seansData: [String: Any] = [
            "ogrenci_id": secilenOgrenciID,
            "ogrenci_ismi": secilenOgrenci?.isim ?? "-",
            "tarih": formattedTarih(date: secilenTarih),
            "saat": secilenSaat,
            "tur": secilenTur,
            "durum": "bekliyor",
            "onaylandi": true,
            "ogretmen_id": ogretmenID
        ]

        db.collection("seanslar").addDocument(data: seansData)
    }

    private func formattedTarih(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

struct Ogrenci: Identifiable {
    let id: String
    let isim: String
}
