import SwiftUI

struct VeliKodGirisView: View {
    @EnvironmentObject var loginVM: LoginViewModel
    @State private var showErrorAlert = false
    @State private var navigateToTakvim = false
    @State private var showAdminLogin = false
    @State private var logoAnimate = false

    var body: some View {
        ZStack {
            // Arkada pastel bir gradyan
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.9, green: 0.95, blue: 1), Color(red: 1, green: 0.92, blue: 0.9)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 28) {
                Spacer()
                
                // Kirpi Logo & SUSU başlık
                VStack(spacing: 8) {
                    Image("susuLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 160)
                        .shadow(color: .gray.opacity(0.5), radius: 12, x: 0, y: 8)
                        .opacity(logoAnimate ? 1 : 0)
                        .scaleEffect(logoAnimate ? 1 : 0.8)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7), value: logoAnimate)
                    
                    Text("SUSU")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(Color("AccentColor"))
                        .shadow(radius: 3)
                }
                .padding(.top)
                
                Text("👋 Veli Girişi")
                    .font(.title2.bold())
                    .foregroundColor(.purple)
                    .padding(.bottom, 6)

                VStack(spacing: 18) {
                    TextField("4 haneli kod", text: $loginVM.girisKodu)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.center)
                        .font(.title2)
                        .frame(width: 160)
                        .onChange(of: loginVM.girisKodu) { yeniDeger in
                            let filtered = yeniDeger.filter { $0.isNumber }
                            if filtered != yeniDeger {
                                loginVM.girisKodu = filtered
                            }
                            if loginVM.girisKodu.count > 4 {
                                loginVM.girisKodu = String(loginVM.girisKodu.prefix(4))
                            }
                        }
                    
                    Button(action: {
                        loginVM.signInWithCode { basarili in
                            if basarili, loginVM.currentVeliID != nil {
                                navigateToTakvim = true
                            } else {
                                showErrorAlert = true
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "key.fill")
                            Text("Giriş Yap")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .cornerRadius(14)
                        .shadow(color: .purple.opacity(0.25), radius: 6, x: 0, y: 4)
                    }
                    .disabled(loginVM.girisKodu.count != 4)
                }
                .padding(.horizontal, 32)

                Spacer()
                
                Button {
                    showAdminLogin = true
                } label: {
                    Text("👩‍🏫 Öğretmen Girişi")
                        .underline()
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .sheet(isPresented: $showAdminLogin) {
                    AdminLoginView().environmentObject(loginVM)
                }
                
                NavigationLink(
                    destination: VeliTabView(veliID: loginVM.currentVeliID ?? "", loginVM: loginVM),
                    isActive: $navigateToTakvim
                ) {
                    EmptyView()
                }
            }
            .padding(.vertical)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    logoAnimate = true
                }
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Giriş Hatası"),
                    message: Text(loginVM.hataMesaji),
                    dismissButton: .default(Text("Tamam"))
                )
            }
        }
    }
}
