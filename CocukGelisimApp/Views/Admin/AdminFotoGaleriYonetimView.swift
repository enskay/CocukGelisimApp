import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct AdminFotoGaleriYonetimView: View {
    @StateObject private var galeriVM = VeliFotoGaleriViewModel()
    @State private var duzenlenenBaslik: String = ""
    @State private var duzenlenenAciklama: String = ""
    @State private var seciliFoto: GaleriFoto?
    @State private var showEditAlert = false
    @State private var showDeleteAlert = false
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(galeriVM.fotograflar) { foto in
                    HStack(spacing: 12) {
                        AsyncImage(url: URL(string: foto.url)) { phase in
                            if let img = phase.image {
                                img.resizable().scaledToFill().frame(width: 80, height: 80).cornerRadius(10)
                            } else {
                                ProgressView().frame(width: 80, height: 80)
                            }
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(foto.baslik).font(.headline)
                            Text(foto.tarih, style: .date).font(.caption)
                            Text("Ekleyen: \(foto.yukleyen)").font(.caption2).foregroundColor(.gray)
                        }
                        Spacer()
                        Button {
                            seciliFoto = foto
                            duzenlenenBaslik = foto.baslik
                            duzenlenenAciklama = foto.aciklama
                            showEditAlert = true
                        } label: {
                            Image(systemName: "pencil")
                        }
                        .buttonStyle(.borderless)
                        Button(role: .destructive) {
                            seciliFoto = foto
                            showDeleteAlert = true
                        } label: {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.borderless)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Fotoğrafları Yönet")
            .refreshable {
                galeriVM.fotograflariYukle()
            }
            .onAppear {
                galeriVM.fotograflariYukle()
            }
            .alert("Düzenle", isPresented: $showEditAlert, actions: {
                TextField("Başlık", text: $duzenlenenBaslik)
                TextField("Açıklama", text: $duzenlenenAciklama)
                Button("Kaydet") {
                    if let foto = seciliFoto {
                        guncelle(fotoID: foto.id, yeniBaslik: duzenlenenBaslik, yeniAciklama: duzenlenenAciklama)
                    }
                }
                Button("Vazgeç", role: .cancel) {}
            }, message: {
                Text("Başlık ve açıklama güncelle")
            })
            .alert("Fotoğraf Sil", isPresented: $showDeleteAlert, actions: {
                Button("Sil", role: .destructive) {
                    if let foto = seciliFoto {
                        fotoSil(foto: foto)
                    }
                }
                Button("Vazgeç", role: .cancel) {}
            }, message: {
                Text("Fotoğrafı silmek istediğine emin misin?")
            })
            .overlay(
                Group {
                    if isLoading {
                        ProgressView("İşlem yapılıyor...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.ultraThinMaterial)
                    }
                }
            )
        }
    }

    private func guncelle(fotoID: String, yeniBaslik: String, yeniAciklama: String) {
        isLoading = true
        let db = Firestore.firestore()
        db.collection("foto_galeri").document(fotoID).updateData([
            "baslik": yeniBaslik,
            "aciklama": yeniAciklama
        ]) { error in
            isLoading = false
            galeriVM.fotograflariYukle()
        }
    }

    private func fotoSil(foto: GaleriFoto) {
        isLoading = true
        let db = Firestore.firestore()
        let storage = Storage.storage()
        db.collection("foto_galeri").document(foto.id).delete { error in
            if error == nil {
                let storageRef = storage.reference(forURL: foto.url)
                storageRef.delete { _ in
                    isLoading = false
                    galeriVM.fotograflariYukle()
                }
            } else {
                isLoading = false
                galeriVM.fotograflariYukle()
            }
        }
    }
}
