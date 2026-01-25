import SwiftUI

struct HistoryDetailView: View {
    let service: UpcomingService
    
    var body: some View {
        UpcomingServiceDetailView(service: service)
    }
}

#Preview {
    HistoryDetailView(service: UpcomingService(cleanerName: "Maria Silva", date: Date(), status: .finalized, amount: 180, clientRating: 4.8, notes: "Serviço completo."))
        .environmentObject(AuthViewModel())
        .environmentObject(AppearanceSettings())
}
