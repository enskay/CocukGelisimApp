import SwiftUI

struct VeliKodGirisView: View {
    @EnvironmentObject var loginVM: LoginViewModel
    @State private var showErrorAlert = false
    @State private var navigateToTakvim = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            Text("👋 Veli Girişi")
                .font(.largeTitle.bold())

            VStack(spacing: 20) {
                TextField("4 haneli kod", text: $loginVM.girisKodu)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .onChange(of: loginVM.girisKodu) { yeniDeger in
                        let filtered = yeniDeger.filter { $0.isNumber }
                        if filtered != yeniDeger {
                            loginVM.girisKodu = filtered
                        }
                        if loginVM.girisKodu.count > 4 {
                            loginVM.girisKodu = String(loginVM.girisKodu.prefix(4))
                        }
                    }

                Button("Giriş Yap") {
                    loginVM.signInWithCode {
                        if loginVM.currentVeliID != nil {
                            navigateToTakvim = true
                        } else {
                            showErrorAlert = true
                        }
                    }
                }
                .font(.headline)
                .buttonStyle(.borderedProminent)
                .disabled(loginVM.girisKodu.count != 4)
            }
            .padding(.horizontal, 32)

            Spacer()

            NavigationLink(destination: OgretmenLoginView()) {
                Text("👩‍🏫 Öğretmen Girişi")
                    .underline()
                    .font(.headline)
            }

            NavigationLink(
                destination: VeliTabView(veliID: loginVM.currentVeliID ?? ""),
                isActive: $navigateToTakvim
            ) {
                EmptyView()
            }
        }
        .padding()
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Giriş Hatası"),
                message: Text(loginVM.hataMesaji),
                dismissButton: .default(Text("Tamam"))
            )
        }
    }
}
