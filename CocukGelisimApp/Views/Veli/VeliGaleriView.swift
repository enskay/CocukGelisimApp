import SwiftUI

struct VeliGaleriView: View {
    @StateObject var galeriVM = VeliFotoGaleriViewModel()
    @State private var aktifIndex = 0
    let zamanlayici = Timer.publish(every: 4, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 16) {
            if galeriVM.fotograflar.isEmpty {
                ProgressView("Yükleniyor...")
            } else {
                TabView(selection: $aktifIndex) {
                    ForEach(Array(galeriVM.fotograflar.enumerated()), id: \.offset) { idx, foto in
                        VStack(spacing: 10) {
                            AsyncImage(url: URL(string: foto.url)) { img in
                                img.resizable().scaledToFill().frame(height: 230).clipped().cornerRadius(16)
                            } placeholder: {
                                Color.gray.opacity(0.15).frame(height: 230).cornerRadius(16)
                            }
                            Text(foto.baslik)
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(.top, 2)
                        }
                        .tag(idx)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(height: 280)
                .onReceive(zamanlayici) { _ in
                    withAnimation {
                        if !galeriVM.fotograflar.isEmpty {
                            aktifIndex = (aktifIndex + 1) % galeriVM.fotograflar.count
                        }
                    }
                }
            }
        }
        .onAppear { galeriVM.fotograflariYukle() }
        .navigationTitle("Fotoğraf Galerisi")
        .padding(.top)
    }
}
