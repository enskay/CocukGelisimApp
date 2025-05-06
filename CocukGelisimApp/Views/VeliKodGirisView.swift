//
//  VeliKodGirisView.swift
//  CocukGelisimApp
//
//  Created by Enes  on 6.05.2025.
//


import SwiftUI

struct VeliKodGirisView: View {
    @EnvironmentObject var loginVM: LoginViewModel  // Giriş işlemleri için ortam nesnesi
    @State private var showErrorAlert = false       // Hata mesajı alındığında alert göstermek için
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            // Başlık
            Text("👋 Veli Girişi")
                .font(.largeTitle.bold())
            
            // Kod girişi ve giriş butonu
            VStack(spacing: 20) {
                TextField("4 haneli kod", text: $loginVM.girisKodu)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .onChange(of: loginVM.girisKodu) { yeniDeger in
                        // Yalnızca rakamlara izin ver ve 4 haneyle sınırla
                        let filtered = yeniDeger.filter { $0.isNumber }
                        if filtered != yeniDeger {
                            loginVM.girisKodu = filtered
                        }
                        if loginVM.girisKodu.count > 4 {
                            loginVM.girisKodu = String(loginVM.girisKodu.prefix(4))
                        }
                    }
                Button("Giriş Yap") {
                    // Veli kodu ile giriş yap
                    loginVM.signInWithCode()
                }
                .font(.headline)
                .buttonStyle(.borderedProminent)
                .disabled(loginVM.girisKodu.count != 4)  // Kod 4 hane değilse buton pasif
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            // Öğretmen girişi butonu (diğer sayfaya navigasyon)
            NavigationLink(destination: OgretmenLoginView()) {
                Text("👩‍🏫 Öğretmen Girişi")
                    .underline()
                    .font(.headline)
            }
        }
        .padding()
        .onAppear {
            // Ekran açıldığında önceki hata mesajını temizle
            loginVM.hataMesaji = ""
        }
        .alert(isPresented: $showErrorAlert) {
            // Hata varsa uyarı göster
            Alert(title: Text("Giriş Hatası"), message: Text(loginVM.hataMesaji), dismissButton: .default(Text("Tamam")) {
                // Tamam tıklandığında hata mesajını temizle
                loginVM.hataMesaji = ""
            })
        }
        .onChange(of: loginVM.hataMesaji) { yeniMesaj in
            // ViewModel'de hata mesajı set edilince alert göstermek için flag'i ayarla
            showErrorAlert = !yeniMesaj.isEmpty
        }
    }
}