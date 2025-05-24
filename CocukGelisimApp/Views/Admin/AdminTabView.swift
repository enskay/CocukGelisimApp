import SwiftUI

struct AdminTabView: View {
    @EnvironmentObject var loginVM: LoginViewModel
    @State private var cikisAlert = false
    @State private var showFotoYukle = false

    var body: some View {
        TabView {
            AdminMainView()
                .tabItem {
                    Label("Ana Sayfa", systemImage: "house")
                }

            AdminTaleplerView()
                .tabItem {
                    Label("Talepler", systemImage: "tray.and.arrow.down")
                }

            AdminTakvimView()
                .tabItem {
                    Label("Takvim", systemImage: "calendar")
                }

            AdminOgrencilerView()
                .tabItem {
                    Label("Öğrenciler", systemImage: "person.3")
                }

            // İŞLEMLER/MORE TAB
            NavigationStack {
                VStack(spacing: 30) {
                    NavigationLink("👨‍👩‍👧 Yeni Kayıt Oluştur", destination: VeliKayitView())
                        .buttonStyle(.borderedProminent)

                    Button("🖼️ Fotoğraf Paylaş") {
                        showFotoYukle = true
                    }
                    .buttonStyle(.borderedProminent)

                    NavigationLink("🖼️ Fotoğrafları Yönet", destination: AdminFotoGaleriYonetimView())
                        .buttonStyle(.bordered)

                    Button(role: .destructive) {
                        cikisAlert = true
                    } label: {
                        Label("🚪 Çıkış Yap", systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .navigationTitle("İşlemler")
                .alert("Çıkmak istediğinize emin misiniz?", isPresented: $cikisAlert) {
                    Button("İptal", role: .cancel) {}
                    Button("Çıkış Yap", role: .destructive) {
                        loginVM.cikisYap()
                    }
                }
                .sheet(isPresented: $showFotoYukle) {
                    AdminFotoYukleView()
                }
            }
            .tabItem {
                Label("İşlemler", systemImage: "ellipsis.circle")
            }
        }
    }
}
