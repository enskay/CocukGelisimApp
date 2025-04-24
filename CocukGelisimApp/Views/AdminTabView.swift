import SwiftUI
import FirebaseAuth

struct AdminTabView: View {
    @EnvironmentObject var loginVM: LoginViewModel
    @State private var cikisAlert = false

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

            AdminSeansListView()
                .tabItem {
                    Label("Seanslar", systemImage: "calendar")
                }

            AdminOgrencilerView()
                .tabItem {
                    Label("Öğrenciler", systemImage: "person.3.fill")
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
                        loginVM.signOut()
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
