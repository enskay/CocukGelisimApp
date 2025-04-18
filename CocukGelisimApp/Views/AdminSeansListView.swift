import SwiftUI
import FirebaseFirestore

struct AdminSeansListView: View {
    @State private var seanslar: [Seans] = []
    @StateObject private var viewModel = AdminSeansListViewModel()
    
    var body: some View {
        List(seanslar) { seans in
            VStack(alignment: .leading, spacing: 6) {
                Text("👶 Öğrenci: \(seans.ogrenciIsmi)")
                Text("📅 Tarih: \(seans.tarih)")
                Text("🕒 Saat: \(seans.saat)")
                Text("📌 Durum: \(seans.durum.capitalized)")
                
                if let neden = seans.neden, !neden.isEmpty {
                    Text("📝 Neden: \(neden)")
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Button("Katıldı") {
                        viewModel.seansDurumuGuncelle(
                            seansID: seans.id,
                            yeniDurum: "katıldı",
                            ogrenciID: seans.ogrenciID
                        )
                    }
                    
                    Button("Ertelendi") {
                        viewModel.seansDurumuGuncelle(
                            seansID: seans.id,
                            yeniDurum: "ertelendi",
                            ogrenciID: seans.ogrenciID
                        )
                    }
                    
                    Button("Gelmedi") {
                        viewModel.seansDurumuGuncelle(
                            seansID: seans.id,
                            yeniDurum: "gelmedi",
                            ogrenciID: seans.ogrenciID
                        )
                    }
                }
                .buttonStyle(.bordered)
                .font(.caption)
                .padding(.top, 6)
            }
            .padding(.vertical, 8)
        }
        .navigationTitle("Tüm Seanslar")
        .onAppear {
            seanslariYukle()
        }
    }
    
    private func seanslariYukle() {
        let db = Firestore.firestore()
        db.collection("seanslar").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { return }
            
            self.seanslar = docs.compactMap { doc in
                let data = doc.data()
                let tarihStr = data["tarih"] as? String ?? "-"
                
                return Seans(
                    id: doc.documentID,
                    ogrenciIsmi: data["ogrenci_ismi"] as? String ?? "-",
                    tarih: tarihStr,
                    saat: data["saat"] as? String ?? "--:--",
                    tur: data["tur"] as? String ?? "-",
                    durum: data["durum"] as? String ?? "bekliyor",
                    onaylandi: data["onaylandi"] as? Bool ?? false,
                    neden: data["neden"] as? String,
                    ogrenciID: data["ogrenci_id"] as? String ?? ""
                )
            }
        }
    }
        
}
