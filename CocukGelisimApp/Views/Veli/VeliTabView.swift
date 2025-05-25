import SwiftUI

struct VeliTabView: View {
    let veliID: String
    let loginVM: LoginViewModel
    @State private var selectedTab = 0
    @State private var cikisAlert = false

    var body: some View {
        TabView(selection: $selectedTab) {
            VeliHomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Ana Sayfa", systemImage: "house")
                }
                .tag(0)

            VeliGaleriListView(galeriVM: VeliFotoGaleriViewModel())
                .tabItem {
                    Label("Galeri", systemImage: "photo.on.rectangle.angled")
                }
                .tag(1)

            VeliSeanslarimView(loginVM: loginVM)
                .tabItem {
                    Label("Seanslarım", systemImage: "calendar")
                }
                .tag(2)

            VeliTakvimView(veliID: veliID)
                .tabItem {
                    Label("Takvim", systemImage: "calendar.circle")
                }
                .tag(3)

            VStack {
                Spacer()
                Button(role: .destructive) {
                    cikisAlert = true
                } label: {
                    Label("Çıkış Yap", systemImage: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red)
                }
                .alert("Çıkmak istediğinize emin misiniz?", isPresented: $cikisAlert) {
                    Button("İptal", role: .cancel) {}
                    Button("Çıkış Yap", role: .destructive) {
                        loginVM.cikisYap()
                    }
                }
                Spacer()
            }
            .tabItem {
                Label("Çıkış", systemImage: "rectangle.portrait.and.arrow.right")
            }
            .tag(4)
        }
        // Tüm sekmelerde arka plan uygulanır!
        .background(BackgroundImageView())
    }
}
