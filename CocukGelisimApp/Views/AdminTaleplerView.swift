import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AdminTaleplerView: View {
    @StateObject private var viewModel = AdminTaleplerViewModel()
    @State private var seciliTalep: SeansTalebi?
    @State private var onaylaAlert = false
    @State private var reddetAlert = false

    private var ogretmenID: String {
        Auth.auth().currentUser?.uid ?? ""
    }

    var body: some View {
        NavigationStack {
            List(viewModel.talepler) { talep in
                VStack(alignment: .leading, spacing: 6) {
                    Text("👶 Öğrenci: \(talep.ogrenciIsmi)")
                    Text("📅 Tarih: \(talep.tarih)")
                    if !talep.neden.isEmpty {
                        Text("📝 Neden: \(talep.neden)")
                            .foregroundColor(.gray)
                    }

                    HStack {
                        Button("✅ Onayla") {
                            seciliTalep = talep
                            onaylaAlert = true
                        }

                        Button("❌ Reddet") {
                            seciliTalep = talep
                            reddetAlert = true
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.vertical, 6)
            }
            .navigationTitle("Seans Talepleri")
            .onAppear {
                viewModel.talepleriYukle()
            }
            .alert("Seansı onaylamak istiyor musunuz?", isPresented: $onaylaAlert, presenting: seciliTalep) { talep in
                Button("Vazgeç", role: .cancel) {}
                Button("Onayla", role: .destructive) {
                    viewModel.onaylaKaydi(talep: talep, ogretmenID: ogretmenID)
                }
            }
            .alert("Seansı reddetmek istiyor musunuz?", isPresented: $reddetAlert, presenting: seciliTalep) { talep in
                Button("Vazgeç", role: .cancel) {}
                Button("Reddet", role: .destructive) {
                    viewModel.reddet(talep: talep)
                }
            }
        }
    }
}
