import SwiftUI

struct VeliGaleriCardView: View {
    let foto: GaleriFoto

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: foto.url)) { phase in
                if let img = phase.image {
                    img
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .clipped()
                } else if phase.error != nil {
                    Color.red.opacity(0.2)
                } else {
                    ProgressView().frame(height: 180)
                }
            }
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.35), Color.clear]),
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 70)

            VStack(alignment: .leading) {
                Text(foto.baslik)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(foto.tarih, style: .date)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
        }
        .cornerRadius(18)
        .shadow(radius: 5)
        .padding(.horizontal, 6)
    }
}
