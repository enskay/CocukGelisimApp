import SwiftUI

struct AdminTaleplerView: View {
    @StateObject private var viewModel = AdminTaleplerViewModel()
    @State private var seciliTalep: OgretmenSeansTalebi?
    @State private var onayAlertGoster = false
    @State private var redAlertGoster = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.talepler) { talep in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("👶 Öğrenci: \(talep.ogrenciIsmi)")
                        Text("👩‍🏫 Öğretmen: \(talep.ogretmenIsmi)")
                        Text("📆 Tarih: \(tarihGoster(talep.tarih))")
                        Text("🕒 Saat: \(talep.saat)")
                        Text("🎯 Tür: \(talep.tur)")
                        HStack {
                            Button("✅ Onayla") {
                                seciliTalep = talep
                                onayAlertGoster = true
                            }
                            .buttonStyle(.borderedProminent)

                            Button("❌ Reddet") {
                                seciliTalep = talep
                                redAlertGoster = true
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Seans Talepleri")
            .onAppear {
                viewModel.talepleriYukle()
            }
            .alert("Seans Talebini Onayla", isPresented: $onayAlertGoster, presenting: seciliTalep) { talep in
                Button("İptal", role: .cancel) {}
                Button("Onayla", role: .destructive) {
                    viewModel.talebiOnayla(talep: talep) { _ in }
                }
            } message: { talep in
                Text("\(tarihGoster(talep.tarih)) saat \(talep.saat)'de \(talep.ogrenciIsmi) için birebir seans onaylansın mı?")
            }
            .alert("Seans Talebini Reddet", isPresented: $redAlertGoster, presenting: seciliTalep) { talep in
                Button("İptal", role: .cancel) {}
                Button("Reddet", role: .destructive) {
                    viewModel.talebiReddet(talep: talep) { _ in }
                }
            } message: { talep in
                Text("\(tarihGoster(talep.tarih)) saat \(talep.saat)'deki talep reddedilsin mi?")
            }
        }
    }

    private func tarihGoster(_ tarih: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        if let date = formatter.date(from: tarih) {
            let display = DateFormatter()
            display.locale = Locale(identifier: "tr_TR")
            display.dateFormat = "dd MMMM yyyy, EEEE"
            return display.string(from: date)
        }
        return tarih
    }
}
