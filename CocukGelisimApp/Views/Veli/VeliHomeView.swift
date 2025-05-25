import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct VeliHomeView: View {
    @Binding var selectedTab: Int
    @State private var ogrenciIsmi: String = "-"
    @StateObject private var galeriVM = VeliFotoGaleriViewModel()
    @State private var currentIndex = 0
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            BackgroundImageView()

            ScrollView {
                VStack(spacing: 20) {
                    // Logo ve başlık
                    VStack(spacing: 6) {
                        Image(uiImage: UIImage(named: "susuLogo") ?? UIImage())
                            .resizable()
                            .scaledToFit()
                            .frame(height: 90)
                            .clipShape(Circle())
                            .shadow(radius: 8)
                        Text("SuSu")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.susuMor)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                    
                    // Hoş geldin kutusu
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.susuMavi.opacity(0.25))
                            .shadow(radius: 4)
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Hoş Geldin,")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                Text(ogrenciIsmi + " 👶")
                                    .font(.title2.bold())
                            }
                            Spacer()
                        }
                        .padding()
                    }
                    .padding(.horizontal)
                    .frame(height: 72)
                    
                    // Seans kutusu
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.susuYesil.opacity(0.15))
                            .shadow(radius: 3)
                        HStack {
                            Image(systemName: "calendar")
                                .font(.system(size: 26))
                                .foregroundColor(.susuYesil)
                            VStack(alignment: .leading) {
                                Text("Bugünkü Seans")
                                    .font(.headline)
                                Text("🕒 Saat 14:00")
                                    .font(.caption)
                            }
                            Spacer()
                        }
                        .padding()
                    }
                    .padding(.horizontal)
                    .frame(height: 65)
                    
                    // Etkinliklerimiz Slider
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("🎉 Etkinliklerimiz")
                                .font(.title3.bold())
                            Spacer()
                            Button("Tümünü Gör") {
                                selectedTab = 1  // Galeri sekmesine geç
                            }
                            .font(.subheadline.bold())
                            .foregroundColor(.susuMor)
                        }
                        if !galeriVM.fotograflar.isEmpty {
                            TabView(selection: $currentIndex) {
                                ForEach(Array(galeriVM.fotograflar.prefix(6).enumerated()), id: \.1.id) { idx, foto in
                                    VeliGaleriCardView(foto: foto)
                                        .tag(idx)
                                        .onTapGesture {
                                            selectedTab = 1  // Galeri sekmesine geç
                                        }
                                }
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                            .frame(height: 200)
                            .onReceive(timer) { _ in
                                withAnimation {
                                    currentIndex = (currentIndex + 1) % min(galeriVM.fotograflar.count, 6)
                                }
                            }
                        } else {
                            Text("Henüz etkinlik/fotoğraf eklenmedi.")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Öğretmen Paylaşımları Butonu
                    NavigationLink(destination: VeliPaylasimlarView()) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 22))
                                .foregroundColor(.susuPembe)
                            VStack(alignment: .leading) {
                                Text("Öğretmen Paylaşımları")
                                    .font(.headline)
                                Text("Fotoğraf ve yazılara göz at")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color.susuSari.opacity(0.20))
                        .cornerRadius(20)
                        .shadow(radius: 2)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top)
            }
        }
        .onAppear {
            ogrenciIsminiYukle()
            galeriVM.fotograflariYukle()
        }
    }

    private func ogrenciIsminiYukle() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("veliler").document(uid).getDocument { docSnap, _ in
            if let data = docSnap?.data(),
               let ogrenciID = data["ogrenci_id"] as? String {
                db.collection("ogrenciler").document(ogrenciID).getDocument { ogrenciDoc, _ in
                    if let ogrData = ogrenciDoc?.data() {
                        self.ogrenciIsmi = ogrData["isim"] as? String ?? "-"
                    }
                }
            }
        }
    }
}
