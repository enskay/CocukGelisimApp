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
                        .frame(height: 170)
                        .clipped()
                } else if phase.error != nil {
                    Color.gray.opacity(0.3)
                } else {
                    ProgressView().frame(height: 170)
                }
            }
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.22), .clear]), startPoint: .bottom, endPoint: .top)
                .frame(height: 60)
            VStack(alignment: .leading) {
                Text(foto.baslik)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(foto.tarih, style: .date)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(10)
        }
        .cornerRadius(20)
        .shadow(radius: 5)
        .padding(.horizontal, 5)
    }
}
