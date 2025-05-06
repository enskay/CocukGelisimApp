import SwiftUI
import Firebase

@main
struct CocukGelisimApp: App {
    @StateObject private var loginVM = LoginViewModel()  // Uygulamanın oturum yönetimi ViewModel'i

    init() {
        FirebaseApp.configure()  // Firebase'i başlat (daha önce yapıldıysa tekrarlamaya gerek yok)
    }

    var body: some Scene {
        WindowGroup {
            if loginVM.isLoggedIn {
                // Kullanıcı giriş yapmışsa rolüne göre ana ekranı göster
                NavigationStack {
                    if loginVM.isTeacher {
                        // Öğretmen girişi yapıldı -> Admin paneli (tab view)
                        AdminTabView()
                    } else {
                        // Veli girişi yapıldı -> Veli ana ekranı (tab view)
                        VeliTabView()
                    }
                }
                .environmentObject(loginVM)  // loginVM'i alt görünüm hiyerarşisine aktarıyoruz
            } else {
                // Henüz giriş yapılmamışsa Veli giriş ekranını göster
                NavigationStack {
                    VeliKodGirisView()  // 4 haneli kod ile veli girişi ekranı
                }
                .environmentObject(loginVM)  // loginVM'i giriş ekranına aktarıyoruz
            }
        }
    }
}
