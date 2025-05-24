import SwiftUI

struct LoginView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()
                
                Text("👋 Giriş Yap")
                    .font(.largeTitle.bold())
                
                VStack(spacing: 20) {
                    NavigationLink(destination: AdminLoginView()) {
                        Text("👩‍🏫 Öğretmen Girişi")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    NavigationLink(destination: VeliKodGirisView()) {
                        Text("👨‍👧‍👦 Veli Girişi (4 Haneli Kod)")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal, 32)

                Spacer()
            }
            .padding()
        }
    }
}
