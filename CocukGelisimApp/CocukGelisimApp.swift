import SwiftUI
import Firebase

@main
struct CocukGelisimApp: App {
    @StateObject private var loginVM = LoginViewModel()

    init() {
        FirebaseApp.configure() // ✅ Firebase burada başlatılıyor
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if loginVM.isLoggedIn {
                    if loginVM.isTeacher {
                        AdminMainView()
                    } else {
                        VeliTabView()
                    }
                } else {
                    LoginView()
                }
            }
            .environmentObject(loginVM)
        }
    }
}
