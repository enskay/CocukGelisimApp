import SwiftUI

struct VeliGaleriListView: View {
    @ObservedObject var galeriVM: VeliFotoGaleriViewModel
    @State private var showDetail = false
    @State private var seciliFoto: GaleriFoto? = nil

    var body: some View {
        NavigationView {
            List(galeriVM.fotograflar) { foto in
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
                    seciliFoto = foto
                    showDetail = true
                }
            }
            .navigationTitle("Tüm Fotoğraflar")
            .onAppear {
                galeriVM.fotograflariYukle()
            }
        }
        .sheet(isPresented: $showDetail) {
            if let secili = seciliFoto,
               let idx = galeriVM.fotograflar.firstIndex(where: { $0.id == secili.id }) {
                VeliFotoDetayView(fotograflar: galeriVM.fotograflar, currentIndex: idx)
            }
        }
    }
}
