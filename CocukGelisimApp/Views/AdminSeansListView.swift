import SwiftUI

struct AdminSeansListView: View {
    @StateObject private var viewModel = AdminSeansListViewModel()
    @State private var seciliSeans: Seans?
    @State private var gosterSilAlert = false

    let ogretmenSecenekleri = ["Tümü", "Alper", "Elif"]

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Öğretmen Filtrele", selection: $viewModel.ogretmenFiltre) {
                    ForEach(ogretmenSecenekleri, id: \.self) { ogretmen in
                        Text(ogretmen)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: viewModel.ogretmenFiltre) { _ in
                    viewModel.seanslariYukle()
                }

                List(viewModel.seanslar) { seans in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("👶 Öğrenci: \(seans.ogrenciIsmi)")
                        Text("📅 Tarih: \(seans.tarih)")
                        Text("🕒 Saat: \(seans.saat)")
                        Text("👥 Tür: \(seans.tur)")
                        Text("📌 Durum: \(seans.durum.capitalized)")

                        if let neden = seans.neden, !neden.isEmpty {
                            Text("📝 Neden: \(neden)")
                                .foregroundColor(.gray)
                        }

                        Button("🗑️ Sil") {
                            seciliSeans = seans
                            gosterSilAlert = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .padding(.top, 6)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Tüm Seanslar")
            .onAppear {
                viewModel.seanslariYukle()
            }
            .alert("Seans Silme Seçenekleri", isPresented: $gosterSilAlert, presenting: seciliSeans) { seans in
                Button("Vazgeç", role: .cancel) {}

                Button("Sadece Seansı Sil", role: .destructive) {
                    viewModel.sadeceSeansiSil(seansID: seans.id)
                    viewModel.seanslariYukle()
                }

                Button("Sil ve Erteleme Hakkını Düşür", role: .destructive) {
                    viewModel.seansiSilVeErtelemeDusur(seans: seans)
                    viewModel.seanslariYukle()
                }
            } message: { seans in
                Text("“\(seans.ogrenciIsmi)” öğrencisinin seansı silinecek.\nİsterseniz erteleme hakkını da düşebilirsiniz.")
            }
        }
    }
}
