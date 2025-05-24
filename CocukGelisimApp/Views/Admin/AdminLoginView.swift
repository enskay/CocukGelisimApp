//
//  AdminLoginView.swift
//  CocukGelisimApp
//
//  Created by Enes  on 23.05.2025.
//


import SwiftUI

struct AdminLoginView: View {
    @EnvironmentObject var loginVM: LoginViewModel
    @State private var showErrorAlert = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Admin Girişi")
                .font(.title).bold()
                .padding(.bottom, 20)
            TextField("E-posta", text: $loginVM.email)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            SecureField("Şifre", text: $loginVM.password)
                .textFieldStyle(.roundedBorder)
            Button("Giriş Yap") {
                loginVM.signInAdmin()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 10)
        }
        .padding()
        .navigationTitle("Admin Girişi")
        .onAppear {
            loginVM.hataMesaji = ""
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Giriş Hatası"),
                message: Text(loginVM.hataMesaji),
                dismissButton: .default(Text("Tamam")) {
                    loginVM.hataMesaji = ""
                }
            )
        }
        .onChange(of: loginVM.hataMesaji) { yeniMesaj in
            showErrorAlert = !yeniMesaj.isEmpty
        }
    }
}