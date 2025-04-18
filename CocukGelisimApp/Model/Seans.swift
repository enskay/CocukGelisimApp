import Foundation

struct Seans: Identifiable {
    let id: String
    let ogrenciIsmi: String
    let tarih: String
    let saat: String
    let tur: String
    let durum: String
    let onaylandi: Bool
    let neden: String?
    let ogrenciID: String
    let ogretmenID: String

    // 🔁 Manuel initializer (ogrenciID en sonda!)
    init(
        id: String,
        ogrenciIsmi: String,
        tarih: String,
        saat: String,
        tur: String,
        durum: String,
        onaylandi: Bool,
        neden: String? = nil,
        ogrenciID: String,
        ogretmenID: String
    ) {
        self.id = id
        self.ogrenciIsmi = ogrenciIsmi
        self.tarih = tarih
        self.saat = saat
        self.tur = tur
        self.durum = durum
        self.onaylandi = onaylandi
        self.neden = neden
        self.ogrenciID = ogrenciID
        self.ogretmenID = ogretmenID
    }
}
