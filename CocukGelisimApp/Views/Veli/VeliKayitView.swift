//
//  VeliKayitView.swift
//  CocukGelisimApp
//
//  Created by Enes  on 6.05.2025.
//


import SwiftUI
import FirebaseFirestore

struct VeliKayitView: View {
    @State private var ogrenciIsmi = ""
    @State private var dogumTarihi = Date()
    @State private var veliIsmi = ""
    @State private var telefon = ""
    @State private var kayitKodu = ""
    @State private var hataMesaji = ""
    @State private var kayitBasarili = false

    var body: some View {
        VStack(spacing: 16) {
            Text("🧾 Yeni Öğrenci Kaydı")
                .font(.title2.bold())
                .padding(.bottom, 10)

            TextField("👶 Öğrenci İsmi", text: $ogrenciIsmi)
                .textFieldStyle(.roundedBorder)

            DatePicker("🎂 Doğum Tarihi", selection: $dogumTarihi, displayedComponents: .date)

            TextField("👨‍👩‍👧 Veli İsmi", text: $veliIsmi)
                .textFieldStyle(.roundedBorder)

            TextField("📱 Telefon (opsiyonel)", text: $telefon)
                .textFieldStyle(.roundedBorder)

            Button("✅ Kaydı Oluştur") {
                ogrenciKaydet()
            }
            .buttonStyle(.borderedProminent)

            if !kayitKodu.isEmpty {
                Text("📌 Giriş Kodu: \(kayitKodu)")
                    .font(.headline)
                    .foregroundColor(.green)
            }

            if !hataMesaji.isEmpty {
                Text("⚠️ \(hataMesaji)")
                    .foregroundColor(.red)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Yeni Kayıt")
    }

    private func ogrenciKaydet() {
        hataMesaji = ""
        guard !ogrenciIsmi.isEmpty, !veliIsmi.isEmpty else {
            hataMesaji = "Lütfen tüm zorunlu alanları doldurun."
            return
        }

        let db = Firestore.firestore()
        let ogrenciRef = db.collection("ogrenciler").document()
        let ogrenciID = ogrenciRef.documentID

        let yeniKod = String(format: "%04d", Int.random(in: 1000...9999))

        // 🔁 Aynı kodun olup olmadığını kontrol et
        db.collection("veliler").whereField("giris_kodu", isEqualTo: yeniKod).getDocuments { snap, _ in
            if let snap = snap, !snap.isEmpty {
                hataMesaji = "Aynı kod var. Tekrar deneyin."
                return
            }

            // 1️⃣ Öğrenciyi kaydet
            ogrenciRef.setData([
                "isim": ogrenciIsmi,
                "dogumTarihi": Timestamp(date: dogumTarihi),
                "kullanilan_hak": 0,
                "kalan_erteleme": 2,
                "birebir_limit": 6
            ])

            // 2️⃣ Veli kaydı
            db.collection("veliler").document().setData([
                "ogrenci_id": ogrenciID,
                "veliAdi": veliIsmi,
                "telefon": telefon,
                "giris_kodu": yeniKod
            ])

            DispatchQueue.main.async {
                self.kayitKodu = yeniKod
                self.kayitBasarili = true
            }
        }
    }
}