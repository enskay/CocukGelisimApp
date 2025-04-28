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
    @State private var birebirLimit: Int = 6
    @State private var yeniBirebirLimit: String = ""
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
                HStack {
                    Button("➕ Artır") {
                        showAlert(title: "Kullanılan Hak Artır", message: "Artırmak istiyor musunuz?") {
                            kullanilanHak += 1
                            updateOgrenciVerisi("kullanilan_hak", value: kullanilanHak)
                        }
                    }
                    Button("➖ Azalt") {
                        showAlert(title: "Kullanılan Hak Azalt", message: "Azaltmak istiyor musunuz?") {
                            if kullanilanHak > 0 {
                                kullanilanHak -= 1
                                updateOgrenciVerisi("kullanilan_hak", value: kullanilanHak)
                            }
                        }
                    }
                }

                Text("🎯 Kalan Erteleme Hakkı: \(kalanErteleme)")
                HStack {
                    Button("➕ Artır") {
                        showAlert(title: "Erteleme Hakkı Artır", message: "Artırmak istiyor musunuz?") {
                            kalanErteleme += 1
                            updateOgrenciVerisi("kalan_erteleme", value: kalanErteleme)
                        }
                    }
                    Button("➖ Azalt") {
                        showAlert(title: "Erteleme Hakkı Azalt", message: "Azaltmak istiyor musunuz?") {
                            if kalanErteleme > 0 {
                                kalanErteleme -= 1
                                updateOgrenciVerisi("kalan_erteleme", value: kalanErteleme)
                            }
                        }
                    }
                }

                Divider()
                Text("🤝 Birebir Seans Limiti: \(birebirLimit)")
                TextField("Yeni limit girin", text: $yeniBirebirLimit)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                Button("💾 Limiti Güncelle") {
                    if let yeniLimit = Int(yeniBirebirLimit) {
                        Firestore.firestore().collection("ogrenciler").document(ogrenciID).updateData([
                            "birebir_limit": yeniLimit
                        ]) { error in
                            if error == nil {
                                birebirLimit = yeniLimit
                                yeniBirebirLimit = ""
                            }
                        }
                    }
                }
                .buttonStyle(.borderedProminent)

                Divider()
                // Diğer alanlar (grup seans sayısı vs.) burada devam eder...
            }
            .padding()
        }
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

    private func verileriYukle() {
        let db = Firestore.firestore()
        db.collection("ogrenciler").document(ogrenciID).getDocument { snap, _ in
            if let data = snap?.data() {
                self.ogrenciIsmi = data["isim"] as? String ?? "-"
                self.yas = data["yas"] as? Int ?? 0
                self.kalanErteleme = data["kalan_erteleme"] as? Int ?? 0
                self.kullanilanHak = data["kullanilan_hak"] as? Int ?? 0
                self.birebirLimit = data["birebir_limit"] as? Int ?? 6
            }
        }

        db.collection("veliler").whereField("ogrenci_id", isEqualTo: ogrenciID).getDocuments { snap, _ in
            if let veliData = snap?.documents.first?.data() {
                self.veliIsmi = veliData["veliAdi"] as? String ?? "-"
                self.email = veliData["email"] as? String ?? "-"
            }
        }

        // seanslar vs. burada devam eder...
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
}
