import SwiftUI
import FirebaseAuth

struct AdminTabView: View {
    @EnvironmentObject var loginVM: LoginViewModel
    @State private var selectedTab = 0
    @State private var cikisAlert = false

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                AdminMainView()
            }
            .tabItem {
                Label("Ana Sayfa", systemImage: "house")
            }
            .tag(0)

            NavigationStack {
                AdminTaleplerView()
            }
            .tabItem {
                Label("Talepler", systemImage: "tray.and.arrow.down")
            }
            .tag(1)

            NavigationStack {
                AdminOgrencilerView()
            }
            .tabItem {
                Label("Öğrenciler", systemImage: "person.2.fill")
            }
            .tag(2)

            NavigationStack {
                AdminTakvimView()
            }
            .tabItem {
                Label("Takvim", systemImage: "calendar")
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
                        loginVM.signOut()
                    }
                }
                Spacer()
            }
            .tabItem {
                Label("Çıkış", systemImage: "rectangle.portrait.and.arrow.right")
            }
            .tag(4)
        }
    }
}
