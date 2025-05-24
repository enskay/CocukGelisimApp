import SwiftUI

struct VeliTabView: View {
    let veliID: String
    let loginVM: LoginViewModel
    @State private var cikisAlert = false

    var body: some View {
        TabView {
            VeliHomeView()
                .tabItem {
                    Label("Ana Sayfa", systemImage: "house")
                }

            VeliSeanslarimView(loginVM: loginVM)
                .tabItem {
                    Label("Seanslarım", systemImage: "calendar")
                }

            VeliTakvimView(veliID: veliID)
                .tabItem {
                    Label("Takvim", systemImage: "calendar.circle")
                }

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
        }
    }
}
