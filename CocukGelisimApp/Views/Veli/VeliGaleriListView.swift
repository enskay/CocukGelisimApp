import SwiftUI

struct VeliGaleriListView: View {
    @ObservedObject var galeriVM: VeliFotoGaleriViewModel
    @State private var seciliIndex: Int? = nil
    @State private var sheetAcilsinMi = false

    var body: some View {
        ZStack {
            BackgroundImageView()
            ScrollView {
                VStack(spacing: 22) {
                    ForEach(Array(galeriVM.fotograflar.enumerated()), id: \.1.id) { idx, foto in
                        Button(action: {
                            if galeriVM.fotograflar.count > idx {
                                seciliIndex = idx
                                sheetAcilsinMi = true
                            }
                        }) {
                            HStack(spacing: 18) {
                                // Fotoğraf
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white)
                                        .frame(width: 78, height: 78)
                                    AsyncImage(url: URL(string: foto.url)) { phase in
                                        if let img = phase.image {
                                            img.resizable()
                                                .scaledToFill()
                                                .frame(width: 78, height: 78)
                                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                        } else {
                                            ProgressView()
                                                .frame(width: 78, height: 78)
                                        }
                                    }
                                }
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(foto.baslik)
                                        .font(.title3.bold())
                                        .foregroundColor(.black)
                                    Text(foto.tarih, style: .date)
                                        .font(.callout)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 18)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.10), radius: 6, y: 3)
                            )
                            .padding(.horizontal, 12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.top, 26)
            }
        }
        .onAppear { galeriVM.fotograflariYukle() }
        .navigationTitle("Tüm Fotoğraflar")
        .sheet(isPresented: $sheetAcilsinMi, onDismiss: { seciliIndex = nil }) {
            if let idx = seciliIndex, galeriVM.fotograflar.count > idx {
                VeliFotoDetayView(fotograflar: galeriVM.fotograflar, currentIndex: idx)
            }
        }
    }
}
