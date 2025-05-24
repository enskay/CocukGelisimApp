import SwiftUI
import FirebaseFirestore

struct VeliTakvimView: View {
    @StateObject private var viewModel: VeliTalepViewModel
    @State private var secilenTarih = Date()
    @State private var secilenSaat = ""
    @State private var secilenOgretmenID = ""
    @State private var secilenOgretmenIsmi = ""
    @State private var secilenTur = "Birebir"
    @State private var talepBasarili = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    let seansTurleri = ["Birebir", "Grup"]

    init(veliID: String) {
        _viewModel = StateObject(wrappedValue: VeliTalepViewModel(veliID: veliID))
    }

    var body: some View {
        VStack(spacing: 16) {
            DatePicker("Tarih Seç", selection: $secilenTarih, in: Date()..., displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding(.horizontal)

            Picker("Öğretmen Seç", selection: $secilenOgretmenID) {
                ForEach(viewModel.ogretmenler, id: \.id) { ogretmen in
                    Text(ogretmen.isim).tag(ogretmen.id)
                }
            }
            .onChange(of: secilenOgretmenID) { yeniID in
                if let secili = viewModel.ogretmenler.first(where: { $0.id == yeniID }) {
                    secilenOgretmenIsmi = secili.isim
                    viewModel.doluSaatleriYukle(tarih: tarihStr(), ogretmenID: yeniID)
                }
            }
            .pickerStyle(.menu)
            .padding(.horizontal)

            Picker("Seans Türü", selection: $secilenTur) {
                ForEach(seansTurleri, id: \.self) { tur in
                    Text(tur).tag(tur)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            Text("Seans Saati Seç")
                .font(.headline)

            Picker("Saat Seç", selection: $secilenSaat) {
                ForEach(viewModel.tumSaatler, id: \.self) { saat in
                    if viewModel.doluSaatler.contains(saat) {
                        Text("\(saat) (Dolu)").foregroundColor(.gray)
                    } else {
                        Text(saat).tag(saat)
                    }
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 100)

            if !secilenSaat.isEmpty {
                Button("Talebi Gönder") {
                    if viewModel.doluSaatler.contains(secilenSaat) {
                        alertMessage = "Bu saat zaten dolu. Lütfen başka bir saat seçin."
                        showAlert = true
                    } else {
                        alertMessage = "\(tarihStr()) tarihinde saat \(secilenSaat)’de \(secilenOgretmenIsmi) öğretmene '\(secilenTur)' seans talebi göndermek istiyor musunuz?"
                        showAlert = true
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)
            }

            if talepBasarili {
                Text("✅ Talebiniz gönderildi.")
                    .foregroundColor(.green)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.ogretmenleriYukle {
                if let ilk = viewModel.ogretmenler.first {
                    secilenOgretmenID = ilk.id
                    secilenOgretmenIsmi = ilk.isim
                    viewModel.doluSaatleriYukle(tarih: tarihStr(), ogretmenID: ilk.id)
                }
            }
        }
        .alert(isPresented: $showAlert) {
            if viewModel.doluSaatler.contains(secilenSaat) {
                return Alert(
                    title: Text("Uyarı"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("Seans Seç"))
                )
            } else {
                return Alert(
                    title: Text("Onay"),
                    message: Text(alertMessage),
                    primaryButton: .cancel(Text("Vazgeç")),
                    secondaryButton: .default(Text("Gönder")) {
                        viewModel.talepGonder(
                            tarih: tarihStr(),
                            saat: secilenSaat,
                            ogretmenID: secilenOgretmenID,
                            ogretmenIsmi: secilenOgretmenIsmi,
                            tur: secilenTur
                        ) { basarili in
                            if basarili {
                                talepBasarili = true
                                secilenSaat = ""
                                viewModel.doluSaatleriYukle(tarih: tarihStr(), ogretmenID: secilenOgretmenID)
                            }
                        }
                    }
                )
            }
        }
        .navigationTitle("Takvim")
    }

    private func tarihStr() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: secilenTarih)
    }
}
