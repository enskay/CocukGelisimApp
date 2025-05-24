import SwiftUI

struct VeliFotoDetayView: View {
    let fotograflar: [GaleriFoto]
    @State var currentIndex: Int

    var body: some View {
        let foto = fotograflar[currentIndex]

        VStack(spacing: 20) {
            Text(foto.baslik)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .padding(.top, 20)

            ZStack {
                // Fotoğraf
                AsyncImage(url: URL(string: foto.url)) { phase in
                    if let img = phase.image {
                        img
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 340)
                            .cornerRadius(20)
                            .shadow(radius: 8)
                            .padding(.horizontal, 32)
                    } else {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(.systemGray5))
                            .frame(height: 220)
                            .overlay(ProgressView())
                            .padding(.horizontal, 32)
                    }
                }

                // Sade Oklar
                HStack {
                    Button {
                        if currentIndex > 0 { currentIndex -= 1 }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(.gray.opacity(currentIndex == 0 ? 0.3 : 0.8))
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.85))
                                    .shadow(radius: 2)
                            )
                    }
                    .disabled(currentIndex == 0)
                    .padding(.leading, 8)

                    Spacer()

                    Button {
                        if currentIndex < fotograflar.count - 1 { currentIndex += 1 }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(.gray.opacity(currentIndex == fotograflar.count - 1 ? 0.3 : 0.8))
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.85))
                                    .shadow(radius: 2)
                            )
                    }
                    .disabled(currentIndex == fotograflar.count - 1)
                    .padding(.trailing, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: 340, alignment: .center)
            }
            .frame(height: 340)

            // Açıklama
            Text(foto.aciklama)
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.horizontal, 14)
                .padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea(.keyboard)
    }
}
