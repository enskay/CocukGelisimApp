import SwiftUI

struct VeliTabView: View {
    var body: some View {
        TabView {
            VeliDashboardView()
                .tabItem {
                    Label("Ana Sayfa", systemImage: "house")
                }

            VeliTakvimView()
                .tabItem {
                    Label("Takvim", systemImage: "calendar")
                }

            VeliSeanslarimView()
                .tabItem {
                    Label("Seanslarım", systemImage: "list.bullet")
                }
        }
    }
}
