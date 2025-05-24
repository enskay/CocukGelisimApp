import SwiftUI

struct VeliFotoDetayView: View {
    let fotograflar: [GaleriFoto]
    @State var currentIndex: Int

    var body: some View {
        ZStack {
            BackgroundImageView()
            VStack(spacing: 20) {
                // Başlık
                Text(fotograflar[currentIndex].baslik)
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)

                // Fotoğraf / ProgressView yükseklik korumalı!
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .shadow(radius: 6)
                        .frame(width: 330, height: 330)
                    AsyncImage(url: URL(string: fotograflar[currentIndex].url)) { phase in
                        if let img = phase.image {
                            img
                                .resizable()
                                .scaledToFit()
                                .frame(width: 310, height: 310)
                                .cornerRadius(20)
                        } else if phase.error != nil {
                            Color.gray.opacity(0.2)
                                .frame(width: 310, height: 310)
                        } else {
                            ProgressView()
                                .frame(width: 310, height: 310)
                        }
                    }
                }
                .frame(height: 340)
                .padding(.vertical, 2)

                // Açıklama: Sevimli kutucuk içinde, yazı da tatlı!
                HStack {
                    Spacer()
                    Text(fotograflar[currentIndex].aciklama)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(.susuMor)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 22)
                                .fill(Color.susuMavi.opacity(0.17))
                                .shadow(radius: 2, y: 2)
                        )
                        .frame(maxWidth: 370)
                    Spacer()
                }
                .padding(.vertical, 2)

                // Ok butonları sabit!
                HStack(spacing: 32) {
                    Button {
                        if currentIndex > 0 { currentIndex -= 1 }
                    } label: {
                        Image(systemName: "chevron.left.circle.fill")
                            .resizable()
                            .frame(width: 38, height: 38)
                            .foregroundColor(.susuMavi)
                            .opacity(currentIndex == 0 ? 0.5 : 1)
                    }
                    .disabled(currentIndex == 0)

                    Button {
                        if currentIndex < fotograflar.count - 1 { currentIndex += 1 }
                    } label: {
                        Image(systemName: "chevron.right.circle.fill")
                            .resizable()
                            .frame(width: 38, height: 38)
                            .foregroundColor(.susuMavi)
                            .opacity(currentIndex == fotograflar.count-1 ? 0.5 : 1)
                    }
                    .disabled(currentIndex == fotograflar.count-1)
                }
                .padding(.bottom, 8)
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .navigationBarTitleDisplayMode(.inline)
        // Kaydırarak geçiş için gesture eklemek istersen ekleyebilirsin.
    }
}
