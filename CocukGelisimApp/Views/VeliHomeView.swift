import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct VeliHomeView: View {
    @State private var ogrenciIsmi: String = "-"
    @State private var hosgeldinMesaji: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 👋 Hoş geldin mesajı
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
                    
                    // 📅 Bugünkü seans kutusu
                    HStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 24))
                        VStack(alignment: .leading) {
                            Text("Bugünkü Seans")
                                .font(.headline)
                            Text("🕒 Saat 14:00") // Örnek, gerçek veri sonra eklenebilir
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.pastelYesil)
                    .cornerRadius(16)
                    .shadow(radius: 2)
                    .padding(.horizontal)

                    // 📰 Öğretmen Paylaşımları Butonu
                    NavigationLink(destination: VeliPaylasimlarView()) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 24))
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
                        .background(Color.pastelSari)
                        .cornerRadius(16)
                        .shadow(radius: 2)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Ana Sayfa")
            .onAppear {
                ogrenciIsminiYukle()
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
