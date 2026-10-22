//
//  DiaristasListView.swift
//  Diarista facil
//
//  Created by André Machado on 20/01/26.
//

import SwiftUI
import MapKit

struct DiaristasListView: View {
    let criteria: DiaristaSearchCriteria

    private let diaristas: [Diarista] = MockDataService.shared.availableDiaristas()

    @State private var selectedDiaristaID: UUID?
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var serviceBoard: ServiceBoard

    var body: some View {
        VStack(spacing: 16) {
            header
            listSection
            actionSection
        }
        .animation(.default, value: selectedDiaristaID)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Buscar diarista")
                .font(.title.bold())
            if let range = criteria.dateRange {
                Text("Período: \(range.lowerBound, style: .date) – \(range.upperBound, style: .date)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    private var listSection: some View {
        List(diaristas) { diarista in
            DiaristaRow(
                diarista: diarista,
                criteria: criteria,
                isSelected: selectedDiaristaID == diarista.id
            )
            .onTapGesture {
                selectedDiaristaID = diarista.id
            }
        }
        .listStyle(.plain)
        .listRowSeparator(.hidden)
        .listSectionSpacing(.compact)
        .navigationTitle("Diaristas Disponíveis")
    }

    private var actionSection: some View {
        VStack(spacing: 12) {
            if selectedDiaristaID != nil {
                Button(action: hireSelectedDiarista) {
                    Text("Contratar Diarista")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(colors: [.blue, Color.blue.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                        .shadow(color: Color.blue.opacity(0.35), radius: 8, x: 0, y: 4)
                }
            }

            VStack(spacing: 4) {
                Text("Não encontrou uma diarista? Crie um serviço para mais tarde.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                Button(action: createServiceFromCriteria) {
                    Text("Criar serviço")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .stroke(Color.blue, lineWidth: 1.5)
                        )
                }
                .disabled(!canCreateService)
                .opacity(canCreateService ? 1 : 0.5)
            }
        }
        .padding()
    }

    private var canCreateService: Bool {
        criteria.dateRange != nil && criteria.arrivalTime != nil && criteria.departureTime != nil
    }

    private func hireSelectedDiarista() {
        guard
            let diaristaID = selectedDiaristaID,
            let diarista = diaristas.first(where: { $0.id == diaristaID }),
            let range = criteria.dateRange,
            let arrival = criteria.arrivalTime,
            let departure = criteria.departureTime
        else {
            selectedDiaristaID = nil
            dismiss()
            return
        }

        let arrivalDate = combine(day: range.lowerBound, time: arrival)
        let departureDate = combine(day: range.lowerBound, time: departure)
        let newService = UpcomingService(
            cleanerName: diarista.name,
            date: arrivalDate,
            endDate: departureDate,
            status: .pending,
            amount: diarista.price,
            clientRating: diarista.rating,
            notes: criteria.notes
        )
        NotificationCenter.default.post(name: .didHireDiarista, object: newService)
        selectedDiaristaID = nil
        dismiss()
    }

    private func createServiceFromCriteria() {
        guard let range = criteria.dateRange,
              let arrival = criteria.arrivalTime,
              let _ = criteria.departureTime else { return }

        let selectedServices = criteria.services.isEmpty ? ["Serviço personalizado"] : criteria.services
        let priceValue = criteria.desiredPrice ?? Decimal(150)
        let combinedDate = combine(day: range.lowerBound, time: arrival)

        let posting = ServicePosting(
            title: selectedServices.first ?? "Serviço personalizado",
            address: criteria.address.isEmpty ? "Endereço não informado" : criteria.address,
            date: combinedDate,
            serviceTypes: selectedServices,
            price: priceValue,
            coordinate: CLLocationCoordinate2D(latitude: -23.56, longitude: -46.65),
            notes: criteria.notes.isEmpty ? nil : criteria.notes,
            clientRating: 4.5,
            attachments: criteria.attachments
        )

        serviceBoard.addPosting(posting)
        dismiss()
    }

    private func combine(day: Date, time: Date) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: day)
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        return Calendar.current.date(from: components) ?? day
    }
}

struct DiaristaRow: View {
    let diarista: Diarista
    let criteria: DiaristaSearchCriteria
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .blue : .gray)
                .font(.title)

            Image(systemName: diarista.avatar)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .foregroundColor(.gray)

            VStack(alignment: .leading, spacing: 8) {
                Text(diarista.name)
                    .font(.headline)
                matchRow
                if isSelected {
                    ratingRow
                }
            }
            Spacer()
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        .background(.ultraThinMaterial)
        .cornerRadius(15)
    }

    private var ratingRow: some View {
        HStack {
            ForEach(0..<5) { index in
                Image(systemName: index < Int(diarista.rating.rounded(.down)) ? "star.fill" : "star")
                    .foregroundColor(.yellow)
            }
            Text(String(format: "%.1f", diarista.rating))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .transition(.opacity)
    }

    private var matchRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            MatchIndicator(label: "Valor", state: priceMatchState)
            MatchIndicator(label: "Endereço", state: addressMatchState)
            MatchIndicator(label: "Serviços", state: serviceMatchState)
            Text("Valor cobrado: \(CurrencyFormatter.string(from: diarista.price))")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("Atende: \(diarista.coverageAreas.joined(separator: ", "))")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("Oferece: \(diarista.services.joined(separator: ", "))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var priceMatchState: MatchState {
        guard let desired = criteria.desiredPrice else { return .notApplicable }
        return diarista.price <= desired ? .match : .mismatch
    }
    
    private var addressMatchState: MatchState {
        guard !criteria.address.isEmpty else { return .notApplicable }
        let normalized = criteria.address.normalized
        let matches = diarista.coverageAreas.contains { $0.normalized.contains(normalized) }
        return matches ? .match : .mismatch
    }
    
    private var serviceMatchState: MatchState {
        guard !criteria.services.isEmpty else { return .notApplicable }
        let diaristaServices = diarista.services.map { $0.lowercased() }
        let matches = criteria.services.allSatisfy { service in
            diaristaServices.contains { $0.contains(service.lowercased()) }
        }
        return matches ? .match : .mismatch
    }
}

struct MatchIndicator: View {
    let label: String
    let state: MatchState
    
    var body: some View {
        HStack(spacing: 6) {
            Text("\(label):")
                .font(.subheadline)
            Image(systemName: state.iconName)
                .foregroundColor(state.iconColor)
            Text(state.description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .font(.subheadline)
        .foregroundColor(.secondary)
    }
}

enum MatchState {
    case match
    case mismatch
    case notApplicable

    var iconName: String {
        switch self {
        case .match: return "checkmark.seal.fill"
        case .mismatch: return "xmark.seal.fill"
        case .notApplicable: return "minus.circle"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .match: return .green
        case .mismatch: return .red
        case .notApplicable: return .gray
        }
    }
    
    var description: String {
        switch self {
        case .match: return "Cheque"
        case .mismatch: return "Fora dos critérios"
        case .notApplicable: return "—"
        }
    }
}

struct DiaristaSearchCriteria {
    var services: [String] = []
    var desiredPrice: Decimal?
    var address: String = ""
    var dateRange: ClosedRange<Date>?
    var arrivalTime: Date?
    var departureTime: Date?
    var notes: String = ""
    var attachments: [CleaningAttachment] = []
}

#Preview {
    NavigationView {
        DiaristasListView(criteria: DiaristaSearchCriteria())
    }
    .environmentObject(AuthViewModel())
    .environmentObject(ServiceBoard())
    .environmentObject(AppearanceSettings())
}
