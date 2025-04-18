import SwiftUI
import FirebaseAuth

struct AdminMainView: View {
    @StateObject private var viewModel = AdminMainViewModel()
    @EnvironmentObject var loginVM: LoginViewModel

    @State private var seansEkleAktif = false
    @State private var cikisAlert = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {

                HStack {
                    Text("📋 Admin Paneli")
                        .font(.title2)
                        .bold()
                    Spacer()
                    Button(action: {
                        seansEkleAktif = true
                    }) {
                        Label("Seans Ekle", systemImage: "plus")
                    }
                }

                Text("👤 Kullanıcı: \(Auth.auth().currentUser?.email ?? "-")")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text("👋 Merhaba, \(viewModel.teacherName)")
                    .font(.headline)

                NavigationLink("📖 Seansları Gör", destination: AdminSeansListView())
                    .padding(.top, 5)

                Text("📅 Bugünkü Seanslar")
                    .font(.title3)
                    .padding(.top, 10)

                if viewModel.todaySessions.isEmpty {
                    Text("Bugün için seans bulunmuyor.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(viewModel.todaySessions, id: \.id) { seans in
                        VStack(alignment: .leading) {
                            Text("👶 Öğrenci: \(seans.ogrenciIsmi)")
                            Text("🕒 Saat: \(seans.saat)")
                            Text("👥 Tür: \(seans.tur)")
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }

                Text("🔁 Kayıt Yenileme Talepleri")
                    .font(.title3)
                    .padding(.top, 20)

                if viewModel.yenilemeTalepleri.isEmpty {
                    Text("Bekleyen talep yok.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(viewModel.yenilemeTalepleri, id: \.id) { veli in
                        HStack {
                            Text("\(veli.veliAdi)")
                            Spacer()
                            Button("Onayla") {
                                viewModel.onaylaKaydi(for: veli.id)
                            }
                            .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(10)
                    }
                }

                Spacer()

                HStack {
                    Spacer()
                    Button(role: .destructive) {
                        cikisAlert = true
                    } label: {
                        Label("🚪 Çıkış Yap", systemImage: "rectangle.portrait.and.arrow.right")
                            .font(.body)
                    }
                    .alert("Çıkmak istediğinize emin misiniz?", isPresented: $cikisAlert) {
                        Button("İptal", role: .cancel) {}
                        Button("Çıkış Yap", role: .destructive) {
                            loginVM.signOut()
                        }
                    }
                }
                .padding(.bottom, 12)
            }
            .padding()
            .onAppear {
                viewModel.fetchAdminVerileri()
            }
            .navigationDestination(isPresented: $seansEkleAktif) {
                AdminSeansEkleView()
            }
        }
    }
}
