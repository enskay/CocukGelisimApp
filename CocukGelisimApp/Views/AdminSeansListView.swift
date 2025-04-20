import SwiftUI

struct AdminSeansListView: View {
    @StateObject private var viewModel = AdminSeansListViewModel()

    var body: some View {
        NavigationStack {
            List(viewModel.seanslar) { seans in
                VStack(alignment: .leading, spacing: 6) {
                    Text("👶 Öğrenci: \(seans.ogrenciIsmi)")
                    Text("📅 Tarih: \(seans.tarih)")
                    Text("🕒 Saat: \(seans.saat)")
                    Text("📌 Durum: \(seans.durum.capitalized)")

                    if let neden = seans.neden, !neden.isEmpty {
                        Text("📝 Neden: \(neden)")
                            .foregroundColor(.gray)
                    }

                    HStack {
                        Button("Katıldı") {
                            viewModel.seansDurumuGuncelle(
                                seansID: seans.id,
                                yeniDurum: "katıldı",
                                ogrenciID: seans.ogrenciID
                            )
                        }

                        Button("Ertelendi") {
                            viewModel.seansDurumuGuncelle(
                                seansID: seans.id,
                                yeniDurum: "ertelendi",
                                ogrenciID: seans.ogrenciID
                            )
                        }

                        Button("Gelmedi") {
                            viewModel.seansDurumuGuncelle(
                                seansID: seans.id,
                                yeniDurum: "gelmedi",
                                ogrenciID: seans.ogrenciID
                            )
                        }

                        Button("Sil") {
                            viewModel.seansiSil(seansID: seans.id)
                        }
                        .tint(.red)
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
                    .padding(.top, 6)
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("Tüm Seanslar")
            .onAppear {
                viewModel.seanslariYukle()
            }
        }
    }
}
