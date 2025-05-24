import SwiftUI

struct VeliPaylasimlarView: View {
    @StateObject private var galeriVM = VeliFotoGaleriViewModel()
    @State private var showDetail = false
    @State private var seciliIndex: Int? = nil

    var body: some View {
        NavigationView {
            List(galeriVM.fotograflar.indices, id: \.self) { idx in
                let foto = galeriVM.fotograflar[idx]
                HStack {
                    AsyncImage(url: URL(string: foto.url)) { phase in
                        if let img = phase.image {
                            img.resizable().scaledToFill().frame(width: 80, height: 80).cornerRadius(10)
                        } else {
                            ProgressView()
                                .frame(width: 80, height: 80)
                        }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(foto.baslik).font(.headline)
                        Text(foto.tarih, style: .date).font(.caption)
                    }
                }
                .padding(.vertical, 6)
                .onTapGesture {
                    seciliIndex = idx
                    showDetail = true
                }
            }
            .navigationTitle("Tüm Fotoğraflar")
            .onAppear {
                galeriVM.fotograflariYukle()
            }
            .sheet(isPresented: $showDetail) {
                if let idx = seciliIndex {
                    VeliFotoDetayView(fotograflar: galeriVM.fotograflar, currentIndex: idx)
                }
            }
        }
    }
}
