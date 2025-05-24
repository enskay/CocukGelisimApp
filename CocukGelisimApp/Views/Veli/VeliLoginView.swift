import SwiftUI
import FirebaseFirestore

struct VeliLoginView: View {
    @State private var girisKodu = ""
    @State private var hataMesaji = ""
    @EnvironmentObject var loginVM: LoginViewModel
    @State private var navigate = false

    var body: some View {
        VStack(spacing: 30) {
            Text("🔐 Veli Girişi")
                .font(.largeTitle.bold())

            TextField("4 Haneli Kod", text: $girisKodu)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            if !hataMesaji.isEmpty {
                Text(hataMesaji)
                    .foregroundColor(.red)
            }

            Button("Giriş Yap") {
                girisYap()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .onChange(of: loginVM.isLoggedIn) { newVal in
            if newVal {
                navigate = true
            }
        }
        .background(
            NavigationLink(
                destination: VeliTabView(
                    veliID: loginVM.currentVeliID ?? "",
                    loginVM: loginVM
                ),
                isActive: $navigate
            ) {
                EmptyView()
            }
            .hidden()
        )
    }

    private func girisYap() {
        loginVM.girisKodu = girisKodu
        loginVM.signInWithCode { basarili in
            if !basarili {
                self.hataMesaji = loginVM.hataMesaji
            }
        }
    }
}
