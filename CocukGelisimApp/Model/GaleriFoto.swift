
import Foundation
import FirebaseFirestore

struct GaleriFoto: Identifiable {
    var id: String
    var url: String
    var baslik: String
    var aciklama: String
    var yukleyen: String
    var tarih: Date
    
    
}
