import SwiftUI
import FirebaseStorage
import FirebaseFirestore

struct AdminFotoYukleView: View {
    @Environment(\.dismiss) var dismiss
    @State private var baslik: String = ""
    @State private var aciklama: String = ""
    @State private var seciliGorsel: UIImage?
    @State private var showImagePicker = false
    @State private var yukleniyor = false
    @State private var showSuccessAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Button(action: {
                    showImagePicker = true
                }) {
                    if let img = seciliGorsel {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 220, maxHeight: 220)
                            .cornerRadius(14)
                    } else {
                        VStack {
                            Image(systemName: "plus.square")
                                .resizable()
                                .frame(width: 60, height: 60)
                            Text("Fotoğraf Seç")
                        }
                    }
                }
                .padding(.top)

                TextField("Başlık", text: $baslik)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                TextField("Açıklama", text: $aciklama)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                Button("Fotoğrafı Yükle") {
                    fotoYukle()
                }
                .buttonStyle(.borderedProminent)
                .disabled(baslik.isEmpty || aciklama.isEmpty || seciliGorsel == nil || yukleniyor)

                Spacer()
            }
            .padding()
            .navigationTitle("Fotoğraf Paylaş")
            .sheet(isPresented: $showImagePicker, content: {
                ImagePicker(image: $seciliGorsel) // <-- Doğru parametre
            })
            .alert("Başarıyla Yüklendi!", isPresented: $showSuccessAlert) {
                Button("Tamam") {
                    dismiss()
                }
            }
        }
    }

    private func fotoYukle() {
        guard let image = seciliGorsel,
              let imageData = image.jpegData(compressionQuality: 0.7) else { return }

        yukleniyor = true
        let uuid = UUID().uuidString
        let ref = Storage.storage().reference().child("galeri/\(uuid).jpg")
        ref.putData(imageData, metadata: nil) { _, error in
            if error == nil {
                ref.downloadURL { url, _ in
                    if let url = url {
                        let db = Firestore.firestore()
                        db.collection("foto_galeri").addDocument(data: [
                            "url": url.absoluteString,
                            "baslik": baslik,
                            "aciklama": aciklama,
                            "yukleyen": "Admin",
                            "tarih": Timestamp(date: Date())
                        ]) { _ in
                            yukleniyor = false
                            showSuccessAlert = true
                        }
                    }
                }
            } else {
                yukleniyor = false
            }
        }
    }
}
