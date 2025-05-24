import SwiftUI

struct AdminMainView: View {
    @StateObject private var viewModel = AdminMainViewModel()
    @State private var seansEkleAktif = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {

                HStack {
                    Text("📋 Admin Paneli")
                        .font(.title2)
                        .bold()
                    Spacer()
                    Button(action: {
                        seansEkleAktif = true
                    }) {
                        Label("Seans Ekle", systemImage: "plus")
                    }
                }

                Text("👋 Merhaba, \(viewModel.teacherName)")
                    .font(.headline)

                NavigationLink("📖 Seansları Gör", destination: AdminSeansListView())
                    .padding(.top, 5)

                Text("📅 Bugünkü Seanslar")
                    .font(.title3)
                    .padding(.top, 10)

                if viewModel.todaySessions.isEmpty {
                    Text("Bugün için seans bulunmuyor.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(viewModel.todaySessions, id: \.id) { seans in
                        VStack(alignment: .leading) {
                            Text("👶 Öğrenci: \(seans.ogrenciIsmi)")
                            Text("🕒 Saat: \(seans.saat)")
                            Text("👥 Tür: \(seans.tur)")
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }

                Spacer()
            }
            .padding()
            .onAppear {
                viewModel.fetchAdminVerileri()
            }
            .navigationDestination(isPresented: $seansEkleAktif) {
                AdminSeansEkleView()
            }
        }
    }
}
