import Foundation

struct GaleriFoto: Identifiable, Hashable {
    var id: String
    var url: String
    var baslik: String
    var aciklama: String
    var yukleyen: String
    var tarih: Date
}
