//
//  UpcomingServiceDetailView.swift
//  Diarista facil
//
//  Created by André Machado on 20/01/26.
//

import SwiftUI
import UIKit
import MapKit

struct UpcomingServiceDetailView: View {
    @Binding var service: UpcomingService
    @State private var isEditing = false
    @State private var originalStatus: ServiceStatus?
    
    @State private var date: Date
    @State private var endDate: Date
    @State private var address: String
    @State private var services: String
    @State private var paymentText: String
    @State private var notes: String
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -23.5505, longitude: -46.6333),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    private let readOnly: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    init(service: Binding<UpcomingService>) {
        self._service = service
        self._date = State(initialValue: service.wrappedValue.date)
        self._endDate = State(initialValue: service.wrappedValue.endDate)
        self._address = State(initialValue: "Rua das Flores, 123")
        self._services = State(initialValue: "Limpeza Padrão, Passar Roupa")
        self._paymentText = State(initialValue: CurrencyFormatter.string(from: service.wrappedValue.amount))
        self._notes = State(initialValue: service.wrappedValue.notes)
        self.readOnly = false
    }

    init(service: UpcomingService) {
        self._service = .constant(service)
        self._date = State(initialValue: service.date)
        self._endDate = State(initialValue: service.endDate)
        self._address = State(initialValue: "Rua das Flores, 123")
        self._services = State(initialValue: "Limpeza Padrão, Passar Roupa")
        self._paymentText = State(initialValue: CurrencyFormatter.string(from: service.amount))
        self._notes = State(initialValue: service.notes)
        self.readOnly = true
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                addressSection
                servicesSection
                ratingSection
                notesSection
                paymentSection
                statusSection
                actionSection
                proofSection
                Spacer(minLength: 20)
            }
            .padding(.vertical)
        }
        .navigationTitle("Detalhes do Serviço")
        .toolbar {
            if !readOnly {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: saveOrEdit) {
                        Text(isEditing ? "Salvar" : "Editar")
                    }
                }
            }
        }
        .onAppear { originalStatus = service.status }
        .onChange(of: date) { _, newValue in
            if endDate < newValue {
                endDate = newValue
            }
        }
    }
    
    // MARK: - Sections
    private var headerSection: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.gray.opacity(0.3))
            VStack(alignment: .leading, spacing: 12) {
                Text(service.cleanerName)
                    .font(.title)
                    .fontWeight(.bold)
                if isEditing {
                    DatePicker("Chegada", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("Saída", selection: endDateBinding, in: date..., displayedComponents: [.date, .hourAndMinute])
                } else {
                    Text(date, style: .date)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 16) {
                        infoBadge(title: "Chegada", value: date)
                        infoBadge(title: "Saída", value: endDate)
                    }
                    ratingStars
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var addressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Endereço")
                    .font(.headline)
                Spacer()
                if let url = mapsURL {
                    Link("Ver no Maps", destination: url)
                        .font(.subheadline)
                }
            }
            if isEditing {
                TextField("Endereço", text: $address)
                    .textFieldStyle(.roundedBorder)
            } else {
                Text(address)
                    .font(.body)
            }
            Map(position: .constant(.region(mapRegion)), interactionModes: [])
                .frame(height: 170)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(.horizontal)
    }
    
    private var servicesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Serviços")
                    .font(.headline)
                Spacer()
            }
            if isEditing {
                TextEditor(text: $services)
                    .frame(height: 110)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            } else {
                LazyVGrid(columns: serviceGridColumns, alignment: .leading, spacing: serviceChipSpacing) {
                    ForEach(parsedServices, id: \.self) { item in
                        serviceChip(for: item)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var ratingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Avaliação do cliente")
                .font(.headline)
            ratingStars
        }
        .padding(.horizontal)
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Observações")
                .font(.headline)
            if isEditing {
                TextEditor(text: $notes)
                    .frame(height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            } else {
                Text(notes.isEmpty ? "Sem observações adicionais." : notes)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
    }
    
    private var paymentSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Pagamento")
                .font(.headline)
            if isEditing {
                TextField("Pagamento", text: $paymentText)
                    .textFieldStyle(.roundedBorder)
            } else {
                Text(paymentText)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
            }
        }
        .padding(.horizontal)
    }
    
    private var statusSection: some View {
        HStack {
            Text("Status")
                .font(.headline)
            Spacer()
            if isCleaner && !readOnly {
                StatusButton(status: $service.status)
            } else {
                StatusBadge(status: service.status)
            }
        }
        .padding(.horizontal)
    }
    
    private var actionSection: some View {
        Group {
            if isCleaner && service.status == .pending && !isEditing && !readOnly {
                HStack(spacing: 16) {
                    Button(role: .destructive) {
                        service.status = .denied
                    } label: {
                        Label("Recusar", systemImage: "xmark.circle")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .background(Color.red)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    
                    Button {
                        service.status = .accepted
                    } label: {
                        Label("Aceitar", systemImage: "checkmark.circle")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var proofSection: some View {
        Group {
            if shouldShowProof, let data = service.proofImageData, let image = UIImage(data: data) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Comprovantes do serviço")
                        .font(.headline)
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.gray.opacity(0.35), lineWidth: 1)
                        )
                }
                .padding(.horizontal)
            } else if shouldShowProof {
                Text("Nenhum comprovante disponível para este serviço.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Helpers
    private var parsedServices: [String] {
        services
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    private var mapsURL: URL? {
        let query = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://maps.google.com/?q=\(query)")
    }
    
    private var shouldShowProof: Bool {
        service.status == .finalized
    }

    private var endDateBinding: Binding<Date> {
        Binding(
            get: { endDate },
            set: { newValue in
                endDate = max(newValue, date)
            }
        )
    }

    private func infoBadge(title: String, value: Date) -> some View {
        let background = colorScheme == .dark ? Color.white.opacity(0.12) : Color.primary.opacity(0.08)
        return VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value, style: .time)
                .font(.headline)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(background)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
    
    private func icon(for text: String) -> String {
        let lower = text.lowercased()
        if lower.contains("vidro") { return "drop" }
        if lower.contains("rou") { return "tshirt" }
        if lower.contains("pesad") { return "hammer" }
        return "sparkles"
    }
    
    private func saveOrEdit() {
        guard !readOnly else { return }
        if isEditing {
            service.date = date
            service.endDate = endDate
            if let decimal = CurrencyFormatter.decimal(from: paymentText) {
                service.amount = decimal
                paymentText = CurrencyFormatter.string(from: decimal)
            }
            service.notes = notes
        }
        isEditing.toggle()
    }
    
    private var isCleaner: Bool {
        authViewModel.currentUserType == .cleaner
    }
}

private extension UpcomingServiceDetailView {
    var serviceChipSpacing: CGFloat { -5 }
    
    var serviceGridColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 140), spacing: serviceChipSpacing, alignment: .leading)]
    }
    
    var serviceChipBackground: Color {
        Color.blue
    }
    
    var serviceChipTextColor: Color {
        Color.white
    }
    
    func serviceChip(for item: String) -> some View {
        Label(item, systemImage: icon(for: item))
            .font(.body)
            .foregroundColor(serviceChipTextColor)
            .padding(.vertical, 6)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(serviceChipBackground)
            )
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var ratingStars: some View {
        HStack(spacing: 4) {
            ForEach(0..<5) { index in
                Image(systemName: index < Int(service.clientRating.rounded(.down)) ? "star.fill" : "star")
                    .foregroundColor(.yellow)
            }
            Text(String(format: "%.1f", service.clientRating))
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    UpcomingServiceDetailView(service: .constant(UpcomingService(cleanerName: "Maria Silva", date: Date(), status: .pending, clientRating: 4.8, notes: "Casa com cachorro.")))
        .environmentObject(AuthViewModel())
        .environmentObject(AppearanceSettings())
}
