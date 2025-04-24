import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct OgrenciDetayView: View {
    let ogrenciID: String

    @State private var ogrenciIsmi: String = "-"
    @State private var veliIsmi: String = "-"
    @State private var email: String = "-"
    @State private var yas: Int = 0
    @State private var kalanErteleme: Int = 0
    @State private var kullanilanHak: Int = 0
    @State private var seanslar: [Seans] = []
    @State private var grupSeansSayisiBuAy: Int = 0

    @State private var yeniTarih = Date()
    @State private var yeniSaat = ""
    @State private var yeniTur = "Birebir"
    @State private var ogretmenID = ""

    @State private var showConfirmation = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var onConfirm: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("👶 Öğrenci: \(ogrenciIsmi) (\(yas) yaş)")
                Text("👩‍👧‍👦 Veli: \(veliIsmi)")
                Text("📧 E-posta: \(email)")
                Divider()

                Text("🔁 Kullanılan Hak: \(kullanilanHak)")
                HStack(spacing: 20) {
                    Button("➕ Artır") {
                        showAlert(title: "Kullanılan Hak Artır", message: "Kullanılan hakkı artırmak istiyor musunuz?") {
                            kullanilanHak += 1
                            updateOgrenciVerisi("kullanilan_hak", value: kullanilanHak)
                        }
                    }
                    Button("➖ Azalt") {
                        showAlert(title: "Kullanılan Hak Azalt", message: "Kullanılan hakkı azaltmak istiyor musunuz?") {
                            if kullanilanHak > 0 {
                                kullanilanHak -= 1
                                updateOgrenciVerisi("kullanilan_hak", value: kullanilanHak)
                            }
                        }
                    }
                }

                Text("🎯 Kalan Erteleme Hakkı: \(kalanErteleme)")
                HStack(spacing: 20) {
                    Button("➕ Artır") {
                        showAlert(title: "Erteleme Hakkı Artır", message: "Erteleme hakkını artırmak istiyor musunuz?") {
                            kalanErteleme += 1
                            updateOgrenciVerisi("kalan_erteleme", value: kalanErteleme)
                        }
                    }
                    Button("➖ Azalt") {
                        showAlert(title: "Erteleme Hakkı Azalt", message: "Erteleme hakkını azaltmak istiyor musunuz?") {
                            if kalanErteleme > 0 {
                                kalanErteleme -= 1
                                updateOgrenciVerisi("kalan_erteleme", value: kalanErteleme)
                            }
                        }
                    }
                }

                Divider()
                Text("📆 Bu Ayki Grup Seans Sayısı: \(grupSeansSayisiBuAy)")
                    .foregroundColor(grupSeansSayisiBuAy > 8 ? .red : .primary)
                if grupSeansSayisiBuAy > 8 {
                    Text("⚠️ Öğrenci bu ay 8'den fazla grup seansına katılmış!")
                        .foregroundColor(.red)
                        .font(.subheadline)
                }

                Divider()
                Text("🗓️ Manuel Seans Ekle").font(.headline)

                DatePicker("Tarih Seç", selection: $yeniTarih, displayedComponents: .date)

                TextField("Saat (örnek: 10:30)", text: $yeniSaat)
                    .textFieldStyle(.roundedBorder)

                Picker("Seans Türü", selection: $yeniTur) {
                    Text("Birebir").tag("Birebir")
                    Text("Grup").tag("Grup")
                }
                .pickerStyle(.segmented)

                Button("✅ Seansı Ekle") {
                    manuelSeansEkle()
                }
                .buttonStyle(.borderedProminent)

                Divider()
                Text("📆 Seanslar")
                    .font(.headline)

                ForEach(seanslar) { seans in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("📅 Tarih: \(seans.tarih)")
                        Text("🕒 Saat: \(seans.saat)")
                        Text("👥 Tür: \(seans.tur)")
                        Text("📌 Durum: \(seans.durum)")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle("Öğrenci Detayı")
        .onAppear {
            verileriYukle()
        }
        .alert(alertTitle, isPresented: $showConfirmation) {
            Button("İptal", role: .cancel) {}
            Button("Evet", role: .destructive, action: onConfirm)
        } message: {
            Text(alertMessage)
        }
    }

    private func updateOgrenciVerisi(_ field: String, value: Any) {
        Firestore.firestore().collection("ogrenciler").document(ogrenciID).updateData([
            field: value
        ])
    }

    private func showAlert(title: String, message: String, onConfirmAction: @escaping () -> Void) {
        alertTitle = title
        alertMessage = message
        onConfirm = onConfirmAction
        showConfirmation = true
    }

    private func manuelSeansEkle() {
        let db = Firestore.firestore()

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let tarihStr = formatter.string(from: yeniTarih)

        let yeniSeans: [String: Any] = [
            "ogrenci_id": ogrenciID,
            "ogrenci_ismi": ogrenciIsmi,
            "tarih": tarihStr,
            "saat": yeniSaat,
            "tur": yeniTur,
            "durum": "bekliyor",
            "onaylandi": true,
            "ogretmen_id": ogretmenID
        ]

        db.collection("seanslar").addDocument(data: yeniSeans) { error in
            if error == nil {
                verileriYukle()
                yeniSaat = ""
                yeniTarih = Date()
                yeniTur = "Birebir"
            }
        }
    }

    private func verileriYukle() {
        let db = Firestore.firestore()

        if let currentID = Auth.auth().currentUser?.uid {
            self.ogretmenID = currentID
        }

        db.collection("ogrenciler").document(ogrenciID).getDocument { snap, _ in
            if let data = snap?.data() {
                self.ogrenciIsmi = data["isim"] as? String ?? "-"
                self.yas = data["yas"] as? Int ?? 0
                self.kalanErteleme = data["kalan_erteleme"] as? Int ?? 0
                self.kullanilanHak = data["kullanilan_hak"] as? Int ?? 0
            }
        }

        db.collection("veliler").whereField("ogrenci_id", isEqualTo: ogrenciID).getDocuments { snap, _ in
            if let veliData = snap?.documents.first?.data() {
                self.veliIsmi = veliData["veliAdi"] as? String ?? "-"
                self.email = veliData["email"] as? String ?? "-"
            }
        }

        db.collection("seanslar").whereField("ogrenci_id", isEqualTo: ogrenciID).getDocuments { snap, _ in
            guard let docs = snap?.documents else { return }

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM"

            let bugunkuAy = formatter.string(from: Date())
            var grupSeansSayisi = 0

            self.seanslar = docs.compactMap { doc in
                let d = doc.data()
                let tarihStr = (d["tarih"] as? String) ?? "-"
                if let date = formatter.date(from: String(tarihStr.prefix(7))),
                   formatter.string(from: date) == bugunkuAy,
                   d["tur"] as? String == "Grup" {
                    grupSeansSayisi += 1
                }

                return Seans(
                    id: doc.documentID,
                    ogrenciIsmi: d["ogrenci_ismi"] as? String ?? "-",
                    tarih: tarihStr,
                    saat: d["saat"] as? String ?? "--:--",
                    tur: d["tur"] as? String ?? "-",
                    durum: d["durum"] as? String ?? "-",
                    onaylandi: d["onaylandi"] as? Bool ?? false,
                    neden: d["neden"] as? String,
                    ogrenciID: ogrenciID,
                    ogretmenID: d["ogretmen_id"] as? String ?? ""
                )
            }

            DispatchQueue.main.async {
                self.grupSeansSayisiBuAy = grupSeansSayisi
            }
        }
    }
}
