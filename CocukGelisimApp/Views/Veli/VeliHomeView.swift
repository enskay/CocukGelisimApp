import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct VeliHomeView: View {
    @State private var ogrenciIsmi: String = "-"
    @StateObject private var galeriVM = VeliFotoGaleriViewModel()
    @State private var showGaleri = false
    @State private var currentIndex = 0
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Hoş geldin mesajı
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Merhaba,")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("\(ogrenciIsmi) 👶")
                            .font(.largeTitle.bold())
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.pastelMavi)
                    .cornerRadius(16)
                    .shadow(radius: 3)
                    .padding(.horizontal)
                    
                    // Etkinliklerimiz Slider
                    HStack {
                        Text("🎉 Etkinliklerimiz")
                            .font(.title3.bold())
                        Spacer()
                        Button("Tümünü Gör") {
                            showGaleri = true
                        }
                        .font(.subheadline.bold())
                    }
                    .padding(.horizontal)
                    
                    if !galeriVM.fotograflar.isEmpty {
                        TabView(selection: $currentIndex) {
                            ForEach(Array(galeriVM.fotograflar.prefix(6).enumerated()), id: \.1.id) { idx, foto in
                                VeliGaleriCardView(foto: foto)
                                    .tag(idx)
                                    .onTapGesture { showGaleri = true }
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
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Ana Sayfa")
            .onAppear {
                ogrenciIsminiYukle()
                galeriVM.fotograflariYukle()
            }
            .sheet(isPresented: $showGaleri) {
                VeliGaleriListView(galeriVM: galeriVM)
            }
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
