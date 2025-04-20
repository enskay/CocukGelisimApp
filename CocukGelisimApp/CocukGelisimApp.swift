import SwiftUI
import Firebase

@main
struct CocukGelisimApp: App {
    @StateObject private var loginVM = LoginViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if loginVM.isLoggedIn {
                NavigationStack {
                    if loginVM.isTeacher {
                        AdminTabView()
                    } else {
                        VeliTabView()
                    }
                }
                .environmentObject(loginVM)
            } else {
                LoginView()
                    .environmentObject(loginVM)
            }
        }
    }
}
