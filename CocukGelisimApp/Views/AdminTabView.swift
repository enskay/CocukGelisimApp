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

            AdminTakvimView()
                .tabItem {
                    Label("Takvim", systemImage: "calendar")
                }

            AdminOgrencilerView()
                .tabItem {
                    Label("Öğrenciler", systemImage: "person.3")
                }

            // 🔧 İşlemler sekmesi (çıkış burada)
            NavigationStack {
                VStack(spacing: 30) {
                    NavigationLink("👨‍👩‍👧 Yeni Kayıt Oluştur", destination: VeliKayitView())
                        .buttonStyle(.borderedProminent)

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
                        loginVM.cikisYap()  // ✅ burada düzeltildi
                    }
                }
            }
            .tabItem {
                Label("İşlemler", systemImage: "ellipsis.circle")
            }
        }
    }
}
