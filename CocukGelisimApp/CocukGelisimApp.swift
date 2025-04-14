import SwiftUI
import FirebaseCore

@main
struct CocukGelisimApp: App {
    
    // Firebase'i başlatan init fonksiyonu
    init() {
        
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}
