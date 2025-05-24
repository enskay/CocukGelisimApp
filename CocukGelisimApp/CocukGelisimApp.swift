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
            // Sadece burada NavigationStack olacak!
            if loginVM.isLoggedIn {
                if loginVM.isAdmin {
                    AdminTabView()
                        .environmentObject(loginVM)
                } else {
                    VeliTabView(veliID: loginVM.currentVeliID ?? "", loginVM: loginVM)
                        .environmentObject(loginVM)
                }
            } else {
                VeliKodGirisView()
                    .environmentObject(loginVM)
            }
        }
    }
}
