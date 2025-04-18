import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct VeliSeanslarimView: View {
    @State private var seanslar: [Seans] = []
    @State private var selectedDurum: [String: String] = [:]
    @State private var nedenler: [String: String] = [:]

    var body: some View {
        List(seanslar) { seans in
            VStack(alignment: .leading, spacing: 8) {
                Text("📅 Tarih: \(seans.tarih)")
                Text("🕒 Saat: \(seans.saat)")
                Text("👥 Tür: \(seans.tur)")
                Text("📌 Durum: \(seans.durum.capitalized)")

                Picker("Katılım Durumu", selection: Binding(
                    get: { selectedDurum[seans.id] ?? seans.durum },
                    set: { selectedDurum[seans.id] = $0 }
                )) {
                    Text("Katılacağım").tag("katıldı")
                    Text("Katılamayacağım").tag("gelmedi")
                }
                .pickerStyle(.segmented)

                if selectedDurum[seans.id] == "gelmedi" {
                    TextField("İsterseniz neden belirtin...", text: Binding(
                        get: { nedenler[seans.id] ?? "" },
                        set: { nedenler[seans.id] = $0 }
                    ))
                    .textFieldStyle(.roundedBorder)
                }

                Button("Kaydet") {
                    seansiGuncelle(seansID: seans.id)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 4)
            }
            .padding(.vertical, 8)
        }
        .navigationTitle("Seanslarım")
        .onAppear {
            seanslariYukle()
        }
    }

    private func seanslariYukle() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("veliler").document(uid).getDocument { veliDoc, error in
            guard let data = veliDoc?.data(),
                  let ogrenciID = data["ogrenci_id"] as? String else { return }

            db.collection("seanslar")
                .whereField("ogrenci_id", isEqualTo: ogrenciID)
                .getDocuments { snapshot, error in
                    guard let docs = snapshot?.documents else { return }

                    self.seanslar = docs.compactMap { doc in
                        let d = doc.data()
                        let tarihStr = d["tarih"] as? String ?? "-"

                        return Seans(
                            id: doc.documentID,
                            ogrenciIsmi: d["ogrenci_ismi"] as? String ?? "-",
                            tarih: tarihStr,
                            saat: d["saat"] as? String ?? "--:--",
                            tur: d["tur"] as? String ?? "-",
                            durum: d["durum"] as? String ?? "bekliyor",
                            onaylandi: d["onaylandi"] as? Bool ?? false,
                            neden: d["neden"] as? String,
                            ogrenciID: d["ogrenci_id"] as? String ?? ""
                        )
                    }
                }
        }
    }
    private func seansiGuncelle(seansID: String) {
        let db = Firestore.firestore()
        let yeniDurum = selectedDurum[seansID] ?? "bekliyor"
        let neden = nedenler[seansID] ?? ""

        db.collection("seanslar").document(seansID).updateData([
            "durum": yeniDurum,
            "neden": neden
        ])
    }
}
