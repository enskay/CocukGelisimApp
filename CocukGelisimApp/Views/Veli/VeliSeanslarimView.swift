import SwiftUI

struct VeliSeanslarimView: View {
    let loginVM: LoginViewModel
    @StateObject private var viewModel: VeliSeanslarimViewModel

    @State private var showIptalAlert = false
    @State private var secilenSeans: Seans?

    init(loginVM: LoginViewModel) {
        self.loginVM = loginVM
        _viewModel = StateObject(wrappedValue: VeliSeanslarimViewModel(loginVM: loginVM))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if !viewModel.grupSeanslar.isEmpty {
                    Text("👥 Grup Seansları")
                        .font(.title2.bold())
                        .padding(.horizontal)
                    ForEach(viewModel.tarihListesi, id: \.self) { tarih in
                        if let seanslar = viewModel.grupSeanslar[tarih], !seanslar.isEmpty {
                            Text(tarih)
                                .font(.headline)
                                .padding(.leading)
                            ForEach(seanslar) { seans in
                                seansKart(seans: seans)
                            }
                        }
                    }
                }
                if !viewModel.birebirSeanslar.isEmpty {
                    Text("🧑‍🤝‍🧑 Birebir Seanslar")
                        .font(.title2.bold())
                        .padding(.horizontal)
                    ForEach(viewModel.tarihListesi, id: \.self) { tarih in
                        if let seanslar = viewModel.birebirSeanslar[tarih], !seanslar.isEmpty {
                            Text(tarih)
                                .font(.headline)
                                .padding(.leading)
                            ForEach(seanslar) { seans in
                                seansKart(seans: seans)
                            }
                        }
                    }
                }
                if viewModel.grupSeanslar.isEmpty && viewModel.birebirSeanslar.isEmpty {
                    Text("Henüz seans bulunmuyor.")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .padding(.top)
        }
        .navigationTitle("Seanslarım")
        .onAppear {
            viewModel.seanslariYukle()
        }
        .alert(isPresented: $showIptalAlert) {
            Alert(
                title: Text("Seansı İptal Et"),
                message: Text("Seansı iptal etmek istediğinize emin misiniz?"),
                primaryButton: .destructive(Text("Evet")) {
                    if let seans = secilenSeans {
                        viewModel.seansiIptalEt(seans: seans) { }
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .overlay(
            Group {
                if viewModel.isLoading {
                    ProgressView("İşleniyor...")
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
        )
    }

    private func seansKart(seans: Seans) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🕒 Saat: \(seans.saat)")
            Text("👩‍🏫 Öğretmen: \(seans.ogretmenIsmi)")
            Text("Durum: \(seans.durum.capitalized)")
                .foregroundColor(seans.durum == "iptal" ? .red : .primary)
            if seans.durum == "bekliyor" || seans.durum == "katıldı" {
                Button(action: {
                    secilenSeans = seans
                    showIptalAlert = true
                }) {
                    Text("Seansı İptal Et")
                        .foregroundColor(.red)
                        .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.15))
        .cornerRadius(14)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 2, y: 2)
        .padding(.horizontal)
    }
}
