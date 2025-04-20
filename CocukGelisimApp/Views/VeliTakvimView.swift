import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct VeliTakvimView: View {
    @StateObject private var viewModel = VeliTalepViewModel()
    @State private var secilenTarih = Date()
    @State private var neden = ""
    @State private var ogrenciID = ""
    @State private var ogrenciIsmi = ""
    @State private var talepBasarili = false

    var body: some View {
        VStack(spacing: 20) {
            DatePicker("Tarih Seç", selection: $secilenTarih, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .onChange(of: secilenTarih) { _ in
                    fetchOgrenciBilgisi()
                }

            if viewModel.doluTarihler.contains(tarihStr()) {
                Text("Bu gün dolu. Talep gönderemezsiniz.")
                    .foregroundColor(.red)
            } else {
                TextField("İsteğe bağlı: Neden belirtebilirsiniz...", text: $neden)
                    .textFieldStyle(.roundedBorder)

                Button("Seans Talebi Gönder") {
                    viewModel.talepGonder(
                        tarih: tarihStr(),
                        neden: neden,
                        ogrenciID: ogrenciID,
                        ogrenciIsmi: ogrenciIsmi
                    ) { basarili in
                        talepBasarili = basarili
                    }
                }
                .buttonStyle(.borderedProminent)
            }

            if talepBasarili {
                Text("✅ Talebiniz başarıyla gönderildi.")
                    .foregroundColor(.green)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.doluGunleriYukle()
            fetchOgrenciBilgisi()
        }
        .navigationTitle("Takvim")
    }

    private func tarihStr() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: secilenTarih)
    }

    private func fetchOgrenciBilgisi() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("veliler").document(uid).getDocument { doc, _ in
            let data = doc?.data()
            self.ogrenciID = data?["ogrenci_id"] as? String ?? ""
            self.ogrenciIsmi = data?["ogrenci_ismi"] as? String ?? "-"
        }
    }
}
