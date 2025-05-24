import SwiftUI
import FirebaseFirestore

struct VeliDashboardView: View {
    let loginVM: LoginViewModel

    @State private var veliAdi = ""
    @State private var ogrenciAdi = ""
    @State private var ogrenciYas = ""
    @State private var toplamHak = 0
    @State private var kullanilanHak = 0
    @State private var kalanErteleme = 0
    @State private var ertelemeHakki = 0

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("👋 Merhaba, \(veliAdi)")
                    .font(.title2)
                    .bold()
                Text("👶 Öğrenci: \(ogrenciAdi) (\(ogrenciYas) yaşında)")
                    .font(.headline)
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    Text("🎯 Kalan Hak: \(toplamHak - kullanilanHak) / \(toplamHak)")
                    Text("🔁 Erteleme Hakkı: \(kalanErteleme) / \(ertelemeHakki)")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                Divider()
                VeliSeanslarimView(loginVM: loginVM)
                Spacer()
            }
            .padding()
            .onAppear {
                verileriYukle()
            }
            .navigationTitle("Veli Paneli")
        }
    }

    private func verileriYukle() {
        guard let veliID = loginVM.currentVeliID else { return }
        let db = Firestore.firestore()
        db.collection("veliler").document(veliID).getDocument { doc, error in
            guard let data = doc?.data(),
                  let ogrenciID = data["ogrenci_id"] as? String else { return }
            self.veliAdi = data["veliAdi"] as? String ?? "-"
            db.collection("ogrenciler").document(ogrenciID).getDocument { ogrDoc, err in
                if let ogrData = ogrDoc?.data() {
                    self.ogrenciAdi = ogrData["isim"] as? String ?? "-"
                    if let yas = ogrData["yas"] as? Int {
                        self.ogrenciYas = String(yas)
                    }
                    self.toplamHak = ogrData["toplam_hak"] as? Int ?? 0
                    self.kullanilanHak = ogrData["kullanilan_hak"] as? Int ?? 0
                    self.ertelemeHakki = ogrData["erteleme_hakki"] as? Int ?? 0
                    self.kalanErteleme = ogrData["kalan_erteleme"] as? Int ?? 0
                }
            }
        }
    }
}
