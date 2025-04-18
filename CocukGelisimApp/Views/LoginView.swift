import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var loginVM: LoginViewModel

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "person.crop.circle.badge.checkmark")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue.opacity(0.8))

                Text("Çocuk Gelişim Giriş")
                    .font(.title)
                    .bold()

                VStack(spacing: 16) {
                    TextField("E-posta", text: $loginVM.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 1)

                    SecureField("Şifre", text: $loginVM.password)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 1)
                }
                .padding(.horizontal)

                Button(action: {
                    loginVM.signIn()
                }) {
                    Text("Giriş Yap")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                if !loginVM.hataMesaji.isEmpty {
                    Text(loginVM.hataMesaji)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()
                Text("© 2025 Çocuk Gelişim Uygulaması")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding()
        }
    }
}
