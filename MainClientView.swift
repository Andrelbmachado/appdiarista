//
//  MainClientView.swift
//  Diarista facil
//
//  Created by André Machado on 20/01/26.
//

import SwiftUI
import MapKit
import PhotosUI
#if canImport(UIKit)
import UIKit
#endif

struct MainClientView: View {
    enum InteractionMode {
        case hiring
        case posting
        
        var title: String {
            switch self {
            case .hiring: return "Encontre uma diarista"
            case .posting: return "Crie um serviço"
            }
        }
        
        var buttonTitle: String {
            switch self {
            case .hiring: return "Buscar diaristas"
            case .posting: return "Postar serviço"
            }
        }
    }
    
    let mode: InteractionMode
    
    init(mode: InteractionMode = .hiring) {
        self.mode = mode
    }

    @EnvironmentObject var serviceBoard: ServiceBoard
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismissView
    @State private var selectedDateRange: ClosedRange<Date>?
    @State private var selectedArrivalTime = Date()
    @State private var selectedDepartureTime = Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date()
    @State private var services = [
        Service(name: "Limpeza Padrão"),
        Service(name: "Limpeza Pesada"),
        Service(name: "Passar Roupa"),
        Service(name: "Limpeza de Vidros")
    ]
    @State private var showDiaristasList = false
    @State private var showPostConfirmation = false
    @State private var priceText = "R$ 150"
    @State private var showAddressPicker = false
    @State private var selectedAddressIndex = 0
    @State private var searchCriteria = DiaristaSearchCriteria()
    @State private var notes = ""
    @State private var validationMessage: String?
    @State private var attachments: [CleaningAttachment] = []
    @State private var photoPickerItems: [PhotosPickerItem] = []

    var isDateSelected: Bool {
        selectedDateRange != nil
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    
                    Text(mode.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 20)
                        .padding(.horizontal)

                    VStack(spacing: 20) {
                        Text("Locais")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "house.fill")
                                    .font(.title)
                                    .foregroundColor(.blue)
                                Text(currentAddressTitle)
                                    .font(.headline)
                                Spacer()
                                Button {
                                    showAddressPicker = true
                                } label: {
                                    Image(systemName: "square.and.pencil")
                                        .font(.system(size: 30, weight: .semibold))
                                        .foregroundColor(.blue)
                                }
                            }
                            Text(currentAddress)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(cardBackgroundColor)
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }

                    CalendarView(selectedRange: $selectedDateRange) { _ in
                        withAnimation {
                            proxy.scrollTo("time_section", anchor: .top)
                        }
                    }
                    .padding(.horizontal)

                    if isDateSelected {
                        VStack(spacing: 24) {
                            Text("Defina um horário")
                                .font(.title2)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .id("time_section")
                                .transition(.asymmetric(insertion: .opacity, removal: .opacity))
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Horário de chegada")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    CompactTimePicker(selectedTime: $selectedArrivalTime)
                                }
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Horário de saída")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    CompactTimePicker(selectedTime: $selectedDepartureTime)
                                }
                            }
                            .padding(.horizontal)
                                .transition(.asymmetric(insertion: .opacity, removal: .opacity))
                            VStack(spacing: 16) {
                                Text("Tipo de serviço")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                ServiceSelectionView(services: $services)
                                    .padding(.horizontal)
                            }
                            .transition(.asymmetric(insertion: .opacity, removal: .opacity))
                            VStack(alignment: .leading, spacing: 12) {
                                Text(mode == .posting ? "Valor oferecido" : "Valor desejado")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                TextField(mode == .posting ? "Ex: R$ 180" : "Ex: R$ 200", text: $priceText)
                                    .keyboardType(.decimalPad)
                                    .padding(12)
                                    .background(cardBackgroundColor)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                                    )
                                if mode == .posting {
                                    Text("Observações")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    TextEditor(text: $notes)
                                        .frame(height: 100)
                                        .padding(8)
                                        .background(cardBackgroundColor)
                                        .cornerRadius(16)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                                    )
                                }
                            }
                            .padding(.horizontal)
                            attachmentsSection
                        }
                        .padding(.top, 16)
                    }
                    
                    Spacer(minLength: 80)
                }
                .navigationDestination(isPresented: $showDiaristasList) {
                    DiaristasListView(criteria: searchCriteria)
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button(action: primaryAction) {
                    Text(mode.buttonTitle)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isDateSelected ? Color.blue : Color.gray)
                        .cornerRadius(16)
                        .shadow(radius: 5)
                }
                .disabled(!isDateSelected)
                .padding(.horizontal)
                .padding(.vertical, 16)
                .background(.ultraThinMaterial)
                .alert("Serviço publicado", isPresented: $showPostConfirmation) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text("Seu pedido ficará visível para as diaristas na aba Home.")
                }
            }
            .background(Color(UIColor { trait in
                trait.userInterfaceStyle == .dark ? UIColor.systemBackground : UIColor.systemBackground
            }))
            .animation(.spring(), value: isDateSelected)
            .onChange(of: selectedArrivalTime) { _, newValue in
                if selectedDepartureTime < newValue {
                    selectedDepartureTime = newValue
                }
            }
            .sheet(isPresented: $showAddressPicker) {
                AddressPickerView(addresses: authViewModel.clientAddresses, selectedIndex: $selectedAddressIndex)
            }
            .onAppear(perform: ensureValidAddressSelection)
            .onChange(of: authViewModel.clientAddresses) { _, _ in
                ensureValidAddressSelection()
            }
            .navigationBarTitleDisplayMode(.inline)
            .onReceive(NotificationCenter.default.publisher(for: .didHireDiarista)) { _ in
                dismissView()
            }
            .alert("Atenção", isPresented: Binding(
                get: { validationMessage != nil },
                set: { if !$0 { validationMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(validationMessage ?? "")
            }
            .onChange(of: photoPickerItems) { _, newItems in
                Task { await loadSelectedPhotos(from: newItems) }
            }
        }
    }
    
    private func primaryAction() {
        dismissKeyboard()
        switch mode {
        case .hiring:
            searchAction()
        case .posting:
            postService()
        }
    }
    
    func searchAction() {
        guard let range = selectedDateRange else {
            validationMessage = "Selecione o período em que a diarista trabalhará."
            return
        }
        let start = range.lowerBound
        let end = range.upperBound
        print("Período selecionado: \(start) - \(end)")
        print("Horário de chegada: \(selectedArrivalTime) | saída: \(selectedDepartureTime)")

        let selectedServices = services.filter { $0.isSelected }.map { $0.name }
        print("Serviços selecionados: \(selectedServices)")
        searchCriteria = DiaristaSearchCriteria(
            services: selectedServices,
            desiredPrice: desiredPriceDecimal,
            address: currentAddress,
            dateRange: range,
            arrivalTime: selectedArrivalTime,
            departureTime: selectedDepartureTime,
            notes: notes,
            attachments: attachments
        )
        showDiaristasList = true
    }

    private func postService() {
        guard let range = selectedDateRange else {
            validationMessage = "Informe o período da limpeza antes de publicar."
            return
        }
        let combinedDate = combinedDateTime(day: range.lowerBound, time: selectedArrivalTime)
        let selectedServices = services.filter { $0.isSelected }.map { $0.name }
        let summary = selectedServices.first ?? "Serviço personalizado"
        let priceValue = desiredPriceDecimal ?? Decimal(150)
        let defaultCoordinate = CLLocationCoordinate2D(latitude: -23.56, longitude: -46.65)
        let posting = ServicePosting(
            title: summary,
            address: currentAddress,
            date: combinedDate,
            serviceTypes: selectedServices.isEmpty ? ["Serviço personalizado"] : selectedServices,
            price: priceValue,
            coordinate: defaultCoordinate,
            notes: notes.isEmpty ? nil : notes,
            clientRating: 4.5,
            attachments: attachments
        )
        serviceBoard.addPosting(posting)
        resetForm()
        showPostConfirmation = true
    }

    private func resetForm() {
        selectedDateRange = nil
        selectedArrivalTime = Date()
        selectedDepartureTime = Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date()
        services = services.map { Service(name: $0.name) }
        priceText = "R$ 150"
        notes = ""
        attachments.removeAll()
    }
    
    private func combinedDateTime(day: Date, time: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: day)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        return calendar.date(from: components) ?? day
    }
}

private extension MainClientView {
    var currentAddress: String {
        guard !authViewModel.clientAddresses.isEmpty else {
            return "Nenhum endereço salvo."
        }
        let clamped = min(max(selectedAddressIndex, 0), authViewModel.clientAddresses.count - 1)
        return authViewModel.clientAddresses[clamped]
    }
    
    var currentAddressTitle: String {
        authViewModel.clientAddresses.isEmpty ? "Sem endereço" : "Endereço \(min(max(selectedAddressIndex, 0), authViewModel.clientAddresses.count - 1) + 1)"
    }
    
    func ensureValidAddressSelection() {
        if authViewModel.clientAddresses.isEmpty {
            selectedAddressIndex = 0
        } else if selectedAddressIndex >= authViewModel.clientAddresses.count {
            selectedAddressIndex = 0
        }
    }

    var desiredPriceDecimal: Decimal? {
        let trimmed = priceText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if let currency = CurrencyFormatter.decimal(from: trimmed) {
            return currency
        }
        let digitsOnly = trimmed.replacingOccurrences(of: "[^0-9,\\.]", with: "", options: .regularExpression)
        let normalized = digitsOnly.replacingOccurrences(of: ",", with: ".")
        return Decimal(string: normalized)
    }

    var cardBackgroundColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.08) : Color(.systemGray6)
    }

    func dismissKeyboard() {
        #if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }

    private var attachmentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Fotos do serviço")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            PhotosPicker(selection: $photoPickerItems, matching: .images) {
                Label("Adicionar fotos", systemImage: "camera.fill")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(cardBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .padding(.horizontal)

            if attachments.isEmpty {
                Text("Ainda não há fotos enviadas.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            } else {
                VStack(spacing: 12) {
                    ForEach($attachments) { $attachment in
                        HStack(alignment: .top, spacing: 12) {
                            if let image = attachment.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 72, height: 72)
                                    .clipped()
                                    .cornerRadius(12)
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 72, height: 72)
                                    .overlay(
                                        Image(systemName: "photo")
                                            .foregroundColor(.gray)
                                    )
                            }
                            VStack(alignment: .leading, spacing: 8) {
                                TextField("Descrição", text: $attachment.description, axis: .vertical)
                                    .textInputAutocapitalization(.sentences)
                                    .lineLimit(1...3)
                                    .padding(8)
                                    .background(Color(.secondarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                Button("Remover") {
                                    removeAttachment(attachment)
                                }
                                .font(.footnote)
                                .foregroundColor(.red)
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }

    private func removeAttachment(_ attachment: CleaningAttachment) {
        attachments.removeAll { $0.id == attachment.id }
    }

    private func loadSelectedPhotos(from items: [PhotosPickerItem]) async {
        guard !items.isEmpty else { return }
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                await MainActor.run {
                    attachments.append(CleaningAttachment(imageData: data, description: ""))
                }
            }
        }
        await MainActor.run {
            photoPickerItems.removeAll()
        }
    }
}

struct AddressPickerView: View {
    let addresses: [String]
    @Binding var selectedIndex: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                if addresses.isEmpty {
                    Text("Nenhum endereço salvo. Adicione nas configurações.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(Array(addresses.enumerated()), id: \.offset) { idx, address in
                        Button {
                            selectedIndex = idx
                            dismiss()
                        } label: {
                            HStack {
                                Text(address)
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedIndex == idx {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Escolher endereço")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { dismiss() }
                }
            }
        }
    }
}

struct CompactTimePicker: View {
    @Binding var selectedTime: Date
    @State private var showingPicker = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button {
            showingPicker = true
        } label: {
            Text(selectedTime.formatted(date: .omitted, time: .shortened))
                .font(.title2.bold())
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
        }
        .buttonStyle(.plain)
        .background(cardBackgroundColor)
        .cornerRadius(18)
        .sheet(isPresented: $showingPicker) {
            pickerSheet
        }
    }

    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.08) : Color(.systemGray6)
    }

    @ViewBuilder
    private var pickerSheet: some View {
        NavigationStack {
            DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Fechar") { showingPicker = false }
                    }
                }
        }
        #if os(iOS)
        .modifier(SheetDetentModifier())
        #endif
    }
}

#if os(iOS)
private struct SheetDetentModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.presentationDetents([.height(300)])
        } else {
            content
        }
    }
}
#endif

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title2)
            .fontWeight(.semibold)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .padding(.horizontal)
    }
}

#Preview {
    MainClientView()
        .environmentObject(ServiceBoard())
}

extension Notification.Name {
    static let didRequestServiceCreation = Notification.Name("didRequestServiceCreation")
    static let didHireDiarista = Notification.Name("didHireDiarista")
}
