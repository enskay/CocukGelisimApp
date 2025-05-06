//
//  AdminOgrenciEkleView.swift
//  CocukGelisimApp
//
//  Created by Enes  on 6.05.2025.
//


import SwiftUI

struct AdminOgrenciEkleView: View {
    @StateObject private var viewModel = AdminOgrenciEkleViewModel()
    @Environment(\.dismiss) private var dismiss  // Sheet'i kapatmak için

    // Form alanları için durum değişkenleri
    @State private var parentName: String = ""
    @State private var childName: String = ""
    @State private var ageText: String = ""
    @State private var email: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Veli Bilgileri")) {
                    TextField("Veli Adı", text: $parentName)
                    TextField("Veli Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                Section(header: Text("Öğrenci Bilgileri")) {
                    TextField("Öğrenci Adı", text: $childName)
                    TextField("Yaş", text: $ageText)
                        .keyboardType(.numberPad)
                }
                Section {
                    Button("Kaydet") {
                        // Yeni öğrenci (veli) kaydını ekle
                        viewModel.addStudent(parentName: parentName,
                                             childName: childName,
                                             ageText: ageText,
                                             email: email)
                    }
                }
            }
            .navigationTitle("Öğrenci Ekle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()  // İptal ile sayfayı kapat
                    }
                }
            }
            // Başarılı kayıt sonrası oluşturulan kodu gösteren uyarı
            .alert("Yeni Giriş Kodu", isPresented: $viewModel.kodOlustuAlert, actions: {
                Button("Tamam") {
                    // "Tamam" seçilince sheet kapatılır
                    dismiss()
                }
            }, message: {
                Text("Velinin giriş yapması için kod: \(viewModel.yeniKod)")
            })
            // Hata durumunda uyarı
            .alert(isPresented: $viewModel.hataAlert) {
                Alert(title: Text("Hata"), message: Text(viewModel.hataMesaji ?? "Bilinmeyen bir hata oluştu."), dismissButton: .default(Text("Tamam")))
            }
        }
    }
}