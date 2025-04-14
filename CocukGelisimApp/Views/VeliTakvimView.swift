//
//  VeliTakvimView.swift
//  CocukGelisimApp
//
//  Created by Enes  on 7.04.2025.
//


import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct VeliTakvimView: View {
    @State private var doluTarihler: [String] = []
    @State private var secilenTarih = Date()
    @State private var neden = ""

    @State private var gosterTalepFormu = false
    @State private var ogrenciID = ""
    @State private var ogrenciIsmi = ""

    var body: some View {
        VStack(spacing: 20) {
            DatePicker("Tarih Seç", selection: $secilenTarih, displayedComponents: .date)
                .datePickerStyle(.graphical)

            if doluGunMu(tarih: secilenTarih) {
                Text("❌ Bu gün dolu").foregroundColor(.red)
            } else {
                Button("📤 Talep Oluştur") {
                    gosterTalepFormu = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .navigationTitle("Takvim")
        .onAppear {
            doluGunleriYukle()
            ogrenciBilgisiYukle()
        }
        .sheet(isPresented: $gosterTalepFormu) {
            NavigationStack {
                Form {
                    Section(header: Text("Talep Tarihi")) {
                        Text(tarihString(from: secilenTarih))
                    }

                    Section(header: Text("Açıklama (isteğe bağlı)")) {
                        TextField("Not ekleyebilirsiniz...", text: $neden)
                    }

                    Button("Talebi Gönder") {
                        talepOlustur()
                    }
                }
                .navigationTitle("Seans Talebi")
            }
        }
    }

    private func tarihString(from date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: date)
    }

    private func doluGunMu(tarih: Date) -> Bool {
        let t = tarihString(from: tarih)
        return doluTarihler.contains(t)
    }

    private func doluGunleriYukle() {
        let db = Firestore.firestore()
        db.collection("seanslar").getDocuments { snap, err in
            guard let docs = snap?.documents else { return }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"

            self.doluTarihler = docs.compactMap { doc in
                doc.data()["tarih"] as? String
            }
        }
    }

    private func ogrenciBilgisiYukle() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("veliler").document(uid).getDocument { doc, error in
            guard let data = doc?.data(),
                  let ogrID = data["ogrenci_id"] as? String else { return }

            self.ogrenciID = ogrID

            db.collection("ogrenciler").document(ogrID).getDocument { ogrDoc, err in
                if let ogrData = ogrDoc?.data() {
                    self.ogrenciIsmi = ogrData["isim"] as? String ?? "-"
                }
            }
        }
    }

    private func talepOlustur() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let tarih = tarihString(from: secilenTarih)

        let talep: [String: Any] = [
            "veli_id": uid,
            "ogrenci_id": ogrenciID,
            "ogrenci_ismi": ogrenciIsmi,
            "tarih": tarih,
            "neden": neden
        ]

        db.collection("seans_talepleri").addDocument(data: talep) { error in
            if error == nil {
                gosterTalepFormu = false
                neden = ""
            }
        }
    }
}