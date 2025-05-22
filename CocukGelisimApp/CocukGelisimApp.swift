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
                    if loginVM.isAdmin {
                        AdminTabView()
                    } else {
                        VeliTabView(veliID: loginVM.currentVeliID ?? "")
                    }
                }
                .environmentObject(loginVM)
            } else {
                NavigationStack {
                    VeliKodGirisView()
                }
                .environmentObject(loginVM)
            }
        }
    }
}
