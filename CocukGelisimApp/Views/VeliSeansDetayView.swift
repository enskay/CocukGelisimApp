import SwiftUI
import FirebaseFirestore

struct VeliSeansDetayView: View {
    let seans: Seans
    @State private var gosterUyari = false
    @State private var kalanErteleme = 2

    var body: some View {
        VStack(spacing: 16) {
            Text("👶 Öğrenci: \(seans.ogrenciIsmi)")
            Text("📅 Tarih: \(seans.tarih)")
            Text("🕒 Saat: \(seans.saat)")
            Text("👥 Tür: \(seans.tur)")
            Text("📌 Durum: \(seans.durum.capitalized)")

            if seans.durum != "gelmedi" {
                Button("Seansı İptal Et") {
                    gosterUyari = true
                }
                .foregroundColor(.red)
                .buttonStyle(.borderedProminent)
                .alert("İptal etmek istediğinize emin misiniz?\nİptal ederseniz \(kalanErteleme - 1) erteleme hakkınız kalacak.", isPresented: $gosterUyari) {
                    Button("Vazgeç", role: .cancel) {}
                    Button("İptal Et", role: .destructive) {
                        iptalEt()
                    }
                }
            } else {
                Text("Bu seans için işlem yapılamaz.")
                    .foregroundColor(.gray)
                    .font(.footnote)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Seans Detayı")
    }

    private func iptalEt() {
        let db = Firestore.firestore()
        db.collection("seanslar").document(seans.id).updateData([
            "durum": "ertelendi",
            "neden": "Veli tarafından iptal edildi"
        ])
        // Kalan hak bilgisi db'de varsa ayrıca güncellenebilir
    }
}
