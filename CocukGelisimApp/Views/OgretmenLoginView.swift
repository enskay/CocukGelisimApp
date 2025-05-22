//
//  OgretmenLoginView.swift
//  CocukGelisimApp
//
//  Created by Enes  on 6.05.2025.
//


import SwiftUI

struct OgretmenLoginView: View {
    @EnvironmentObject var loginVM: LoginViewModel  // Ortam nesnesinden LoginViewModel
    @State private var showErrorAlert = false       // Hata alert göstermek için

    var body: some View {
        VStack(spacing: 20) {
            Text("Öğretmen Girişi")
                .font(.title).bold()
                .padding(.bottom, 20)
            // E-posta alanı
            TextField("E-posta", text: $loginVM.email)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            // Şifre alanı
            SecureField("Şifre", text: $loginVM.password)
                .textFieldStyle(.roundedBorder)
            // Giriş yap butonu
            Button("Giriş Yap") {
                loginVM.signInAdmin()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 10)
        }
        .padding()
        .navigationTitle("Öğretmen Girişi")
        .onAppear {
            // Ekran açılırken alanları ve hata mesajını temizle
            loginVM.hataMesaji = ""
            // (Not: İsteğe bağlı olarak email/şifreyi de temizleyebilirsiniz)
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Giriş Hatası"), message: Text(loginVM.hataMesaji), dismissButton: .default(Text("Tamam")) {
                loginVM.hataMesaji = ""
            })
        }
        .onChange(of: loginVM.hataMesaji) { yeniMesaj in
            showErrorAlert = !yeniMesaj.isEmpty
        }
    }
}
