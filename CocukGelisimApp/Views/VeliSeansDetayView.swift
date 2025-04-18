import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct VeliSeansDetayView: View {
    var seans: Seans

    @State private var iptalEdildi = false
    @State private var kalanErteleme: Int = 0
    @State private var showAlert = false
    @State private var alertMesaj = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📅 Tarih: \(seans.tarih)")
            Text("🕒 Saat: \(seans.saat)")
            Text("👥 Tür: \(seans.tur)")
            Text("📌 Durum: \(seans.durum.capitalized)")
            if let neden = seans.neden, !neden.isEmpty {
                Text("📝 Neden: \(neden)")
                    .foregroundColor(.gray)
            }

            if seans.durum == "gelmedi" {
                Text("❌ Bu seansı iptal edemezsiniz.")
                    .foregroundColor(.red)
            } else if seans.durum == "iptal edildi" || iptalEdildi {
                Text("❗️ Seans iptal edildi.")
                    .foregroundColor(.red)
            } else {
                Button("❌ Seansı İptal Et") {
                    showAlert = true
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 16)
                .alert("İptal Onayı", isPresented: $showAlert) {
                    Button("Vazgeç", role: .cancel) {}
                    Button("İptal Et", role: .destructive) {
                        seansiIptalEt()
                    }
                } message: {
                    Text("İptal etmek istediğinize emin misiniz?\nBu işlemden sonra \(kalanErteleme - 1) erteleme hakkınız kalacak.")
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Seans Detayı")
        .onAppear {
            ertelemeHakkiniGetir()
        }
    }

    private func ertelemeHakkiniGetir() {
        let db = Firestore.firestore()
        db.collection("ogrenciler").document(seans.ogrenciID).getDocument { snap, error in
            if let data = snap?.data() {
                self.kalanErteleme = data["kalan_erteleme"] as? Int ?? 0
            }
        }
    }

    private func seansiIptalEt() {
        let db = Firestore.firestore()

        // Seans durumunu güncelle
        db.collection("seanslar").document(seans.id).updateData([
            "durum": "iptal edildi"
        ]) { error in
            if error == nil {
                self.iptalEdildi = true

                // Erteleme hakkını azalt
                let yeniHak = max(self.kalanErteleme - 1, 0)
                db.collection("ogrenciler").document(seans.ogrenciID).updateData([
                    "kalan_erteleme": yeniHak
                ])
            }
        }
    }
}
