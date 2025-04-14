import SwiftUI

struct LoginView: View {
    
    // 🔥 Mutlaka @StateObject olmalı!
    @StateObject private var loginVM = LoginViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()

                Image(systemName: "graduationcap.circle.fill")
                    .resizable()
                    .foregroundColor(.blue.opacity(0.8))
                    .frame(width: 120, height: 120)
                    .padding(.bottom, 30)

                Text("Çocuk Gelişim Merkezi")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Hesabınızla giriş yapın")
                    .foregroundColor(.gray)

                VStack(spacing: 14) {
                    TextField("E-posta", text: $loginVM.email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    SecureField("Şifre", text: $loginVM.password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }

                Button("Giriş Yap") {
                    loginVM.login()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                if !loginVM.loginStatusMessage.isEmpty {
                    Text(loginVM.loginStatusMessage)
                        .foregroundColor(.red)
                }

                Spacer()

                // ✅ Gizli NavigationLink ile yönlendirme
                    .navigationDestination(isPresented: $loginVM.isLoggedIn) {
                        destinationView
                    }
            }
            .padding()
        }
    }

    // ✅ ViewBuilder ile yönlendirme ekranı
    @ViewBuilder
    private var destinationView: some View {
        if loginVM.isTeacher {
            AdminMainView()
        } else {
            VeliDashboardView()
        }
    }
}
