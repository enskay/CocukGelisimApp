import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct VeliTakvimView: View {
    @State private var secilenTarih: Date = Date()
    @State private var doluGun: Bool = false
    @State private var neden: String = ""
    @State private var talepOlusturuldu = false
    @State private var hataMesaji = ""

    var body: some View {
        VStack(spacing: 20) {
            DatePicker("Tarih Seç", selection: $secilenTarih, displayedComponents: .date)
                .datePickerStyle(.graphical)

            if doluGun {
                Text("⚠️ Bu tarihte zaten bir seans var.")
                    .foregroundColor(.red)
            } else {
                TextField("İsterseniz neden belirtin...", text: $neden)
                    .textFieldStyle(.roundedBorder)

                Button("📩 Talep Oluştur") {
                    talepOlustur()
                }
                .buttonStyle(.borderedProminent)
            }

            if talepOlusturuldu {
                Text("✅ Talebiniz iletildi.")
                    .foregroundColor(.green)
            }

            if !hataMesaji.isEmpty {
                Text(hataMesaji)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .navigationTitle("Takvim")
        .onChange(of: secilenTarih) { _ in
            doluGunKontrol()
        }
        .onAppear {
            doluGunKontrol()
        }
    }

    private func doluGunKontrol() {
        let db = Firestore.firestore()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let secilenGunStr = formatter.string(from: secilenTarih)

        db.collection("seanslar")
            .whereField("tarih", isEqualTo: secilenGunStr)
            .getDocuments { snapshot, error in
                if let docs = snapshot?.documents, !docs.isEmpty {
                    doluGun = true
                } else {
                    doluGun = false
                }
            }
    }

    private func talepOlustur() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let tarihStr = formatter.string(from: secilenTarih)

        // Veli üzerinden öğrenci_id çek
        db.collection("veliler").document(uid).getDocument { snap, error in
            guard let data = snap?.data(),
                  let ogrenciID = data["ogrenci_id"] as? String,
                  let ogrenciIsmi = data["ogrenci_ismi"] as? String else {
                self.hataMesaji = "Öğrenci bilgisi alınamadı."
                return
            }

            let talep: [String: Any] = [
                "tarih": tarihStr,
                "ogrenci_id": ogrenciID,
                "ogrenci_ismi": ogrenciIsmi,
                "neden": self.neden
            ]

            db.collection("seans_talepleri").addDocument(data: talep) { error in
                if error == nil {
                    self.talepOlusturuldu = true
                    self.neden = ""
                } else {
                    self.hataMesaji = "Talep oluşturulamadı."
                }
            }
        }
    }
}
