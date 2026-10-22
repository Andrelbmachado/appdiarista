//
//  HomeView.swift
//  Diarista facil
//
//  Created by André Machado on 20/01/26.
//

import SwiftUI
import MapKit

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var serviceBoard: ServiceBoard
    @Environment(\.colorScheme) private var colorScheme
    @State private var searchText = ""
    @State private var showingFilter = false
    @State private var filterOptions = ServiceFilterOptions()
    @State var upcomingServices: [UpcomingService] = MockDataService.shared.upcomingServices()
    @State private var selectedServicePostingID: ServicePosting.ID?
    @State private var scheduledSearchText = ""
    @State private var showingScheduledFilter = false
    @State private var scheduledFilter = ScheduledFilter()

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    Text(isCleaner ? "Painel da Diarista" : "Home")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 0)

                    if isCleaner {
                        searchBar
                        availableServicesSection
                    } else {
                        sectionHeader(title: "Serviços criados")
                        scheduledServicesSection
                    }

                    Spacer(minLength: 60)
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(homeBackgroundColor.ignoresSafeArea())
            .safeAreaInset(edge: .bottom) {
                if !isCleaner {
                    VStack(spacing: 12) {
                        clientActionsSection
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 16)
                    .background(homeBackgroundColor)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .onChangeCompat(of: filteredAvailableServices) { services in
                guard let selectedID = selectedServicePostingID else { return }
                if !services.contains(where: { $0.id == selectedID }) {
                    selectedServicePostingID = nil
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .didHireDiarista)) { notification in
                guard let service = notification.object as? UpcomingService else { return }
                upcomingServices.insert(service, at: 0)
            }
        }
    }
}

private extension HomeView {
    var searchBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.primary.opacity(0.7))
                TextField("Busque por endereço, data ou tipo de serviço", text: $searchText)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.primary.opacity(0.6))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
            Button {
                showingFilter = true
            } label: {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .padding(10)
            }
        }
        .sheet(isPresented: $showingFilter) {
            ServiceFilterView(filter: $filterOptions)
                .environmentObject(authViewModel)
        }
    }

    var scheduledSearchBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.primary.opacity(0.7))
                TextField("Buscar serviços", text: $scheduledSearchText)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                if !scheduledSearchText.isEmpty {
                    Button {
                        scheduledSearchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.primary.opacity(0.6))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
            Button {
                showingScheduledFilter = true
            } label: {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.title3)
                    .foregroundColor(.blue)
                    .padding(10)
            }
        }
        .sheet(isPresented: $showingScheduledFilter) {
            ScheduledFilterView(filter: $scheduledFilter)
        }
    }

    var availableServicesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Serviços disponíveis")
                .font(.title3.bold())
            ZStack(alignment: .bottomTrailing) {
                Map(initialPosition: .region(region(for: filteredAvailableServices))) {
                    ForEach(filteredAvailableServices) { posting in
                        let isSelected = posting.id == selectedServicePostingID
                        Annotation("", coordinate: posting.coordinate) {
                            Button {
                                selectPosting(posting)
                            } label: {
                                VStack(spacing: 4) {
                                    Text(posting.formattedPrice)
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(isSelected ? Color.green : Color.blue)
                                        .foregroundColor(.white)
                                        .clipShape(Capsule())
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(isSelected ? .green : .red)
                                }
                                .scaleEffect(isSelected ? 1.15 : 1)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
            }
            .frame(height: 220)
            if filteredAvailableServices.isEmpty {
                Text("Nenhum serviço encontrado para sua busca.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(orderedAvailableServices) { posting in
                        NavigationLink(destination: ServicePostingDetailView(posting: posting)) {
                            AvailableServiceCard(posting: posting, isSelected: posting.id == selectedServicePostingID)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    var clientActionsSection: some View {
        VStack(spacing: 12) {
            NavigationLink(destination: MainClientView(mode: .hiring)) {
                actionButtonLabel(title: "Contratar diarista", icon: "person.2.fill", tint: .blue)
            }
            NavigationLink(destination: MainClientView(mode: .posting)) {
                actionButtonLabel(title: "Criar serviço", icon: "plus.circle.fill", tint: .black)
            }
        }
    }

    func actionButtonLabel(title: String, icon: String, tint: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
            Text(title)
                .font(.headline)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
        }
        .foregroundColor(.white)
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(colors: [tint, tint.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
        )
        .shadow(color: tint.opacity(0.25), radius: 12, x: 0, y: 6)
    }

    func sectionHeader(title: String) -> some View {
        Text(title)
            .font(.title3.bold())
    }

    var scheduledServicesSection: some View {
        LazyVStack(spacing: 16) {
            scheduledSearchBar
            if filteredServices.isEmpty {
                Text("Nenhum serviço agendado no momento.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(filteredServices) { service in
                    NavigationLink(destination: UpcomingServiceDetailView(service: binding(for: service))) {
                        UpcomingServiceRow(service: binding(for: service), canEditStatus: isCleaner)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}


struct UpcomingServiceRow: View {
    @Binding var service: UpcomingService
    var canEditStatus: Bool
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text(service.cleanerName)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(cardTextColor)
                HStack(spacing: 8) {
                    Text(plainDate(service.date))
                        .font(.subheadline)
                        .foregroundColor(cardTextColor.opacity(0.7))
                    Spacer(minLength: 4)
                    Text(plainTime(service.date))
                        .font(.subheadline)
                        .foregroundColor(cardTextColor.opacity(0.7))
                    Text("-")
                        .font(.subheadline)
                        .foregroundColor(cardTextColor.opacity(0.7))
                    Text(plainTime(service.endDate))
                        .font(.subheadline)
                        .foregroundColor(cardTextColor.opacity(0.7))
                }
            }
            Spacer(minLength: 12)
            HStack(spacing: 12) {
                if canEditStatus {
                    StatusButton(status: $service.status)
                } else {
                    StatusBadge(status: service.status)
                }
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(cardBackground)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(borderColor, lineWidth: colorScheme == .dark ? 1 : 0)
        )
        .shadow(color: cardShadowColor, radius: 4, x: 0, y: 2)
    }
    
    private var cardBackground: Color {
        if colorScheme == .dark {
            return Color(red: 0.19, green: 0.21, blue: 0.25)
        }
        return .white
    }
    
    private var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.4) : .clear
    }
    
    private var cardTextColor: Color {
        colorScheme == .dark ? Color(red: 0.95, green: 0.97, blue: 0.98) : .primary
    }
    
    private var cardShadowColor: Color {
        colorScheme == .dark ? Color.black.opacity(0.35) : Color.black.opacity(0.05)
    }

    private let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()

    private let shortTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private func plainDate(_ date: Date) -> String {
        shortDateFormatter.string(from: date)
    }

    private func plainTime(_ date: Date) -> String {
        shortTimeFormatter.string(from: date)
    }

}

struct AvailableServiceCard: View {
    let posting: ServicePosting
    var isSelected: Bool = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(posting.title)
                        .font(.headline)
                        .foregroundColor(textColor)
                    Text(posting.address)
                        .font(.subheadline)
                        .foregroundColor(textColor.opacity(0.9))
                    Text("\(posting.formattedDate) às \(posting.formattedTime)")
                        .font(.caption)
                        .foregroundColor(textColor.opacity(0.7))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    Text(posting.formattedPrice)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(textColor)
                }
            }
            if !posting.serviceTypes.isEmpty {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 8)], alignment: .leading, spacing: 8) {
                    ForEach(posting.serviceTypes, id: \.self) { service in
                        HStack(spacing: 6) {
                            Image(systemName: icon(for: service))
                                .font(.footnote)
                            Text(service)
                                .font(.footnote)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    }
                }
            }
        }
        .padding()
        .background(cardBackground)
        .cornerRadius(18)
        .shadow(color: shadowColor, radius: 6, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(isSelected ? Color.green : Color.clear, lineWidth: isSelected ? 3 : 0)
                .shadow(color: isSelected ? Color.green.opacity(0.3) : .clear, radius: isSelected ? 6 : 0)
        )
        .scaleEffect(isSelected ? 1.02 : 1)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
    }

    private var cardBackground: Color {
        colorScheme == .dark ? Color(red: 0.16, green: 0.18, blue: 0.22) : .white
    }

    private var textColor: Color {
        colorScheme == .dark ? .white : .primary
    }

    private var shadowColor: Color {
        colorScheme == .dark ? Color.black.opacity(0.35) : Color.black.opacity(0.08)
    }
    
    private func icon(for service: String) -> String {
        let lower = service.lowercased()
        if lower.contains("padr") { return "sparkles" }
        if lower.contains("pesad") { return "hammer" }
        if lower.contains("rou") { return "tshirt" }
        if lower.contains("vidr") { return "drop" }
        return "circle.grid.cross.left.filled"
    }
}

struct StatusBadge: View {
    var status: ServiceStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.subheadline.bold())
            .foregroundColor(statusColor)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(statusColor.opacity(0.15))
            .clipShape(Capsule())
    }
    
    private var statusColor: Color {
        switch status {
        case .pending: return .yellow
        case .accepted: return .green
        case .denied: return .red
        case .awaitingPayment: return .blue
        case .paid: return .teal
        case .finalized: return .gray
        }
    }
}

private extension HomeView {
    private var isCleaner: Bool {
        authViewModel.currentUserType == .cleaner
    }
    
    private var filteredServices: [UpcomingService] {
        var results = upcomingServices.filter { $0.status == .pending }
        let query = scheduledSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            results = results.filter {
                $0.cleanerName.localizedCaseInsensitiveContains(query) ||
                $0.notes.localizedCaseInsensitiveContains(query) ||
                CurrencyFormatter.string(from: $0.amount).localizedCaseInsensitiveContains(query) ||
                DateFormatter.localizedString(from: $0.date, dateStyle: .medium, timeStyle: .short).localizedCaseInsensitiveContains(query)
            }
        }
        if let minDate = scheduledFilter.minDate {
            results = results.filter { $0.date >= minDate }
        }
        if let maxDate = scheduledFilter.maxDate {
            results = results.filter { $0.date <= maxDate }
        }
        if let minPrice = scheduledFilter.minPriceDecimal {
            results = results.filter { $0.amount >= minPrice }
        }
        if let maxPrice = scheduledFilter.maxPriceDecimal {
            results = results.filter { $0.amount <= maxPrice }
        }
        if let status = scheduledFilter.status {
            results = results.filter { $0.status == status }
        }
        return results
    }
    
    private var filteredAvailableServices: [ServicePosting] {
        var results = serviceBoard.postings
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedSearch.isEmpty {
            results = results.filter { $0.matches(query: trimmedSearch) }
        }
        if !filterOptions.addressQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let query = filterOptions.addressQuery.normalized
            results = results.filter { $0.address.normalized.contains(query) }
        }
        if let maxPrice = filterOptions.maxPriceDecimal {
            results = results.filter { $0.price <= maxPrice }
        }
        if !filterOptions.selectedKinds.isEmpty {
            results = results.filter { posting in
                let postingKinds = posting.serviceTypes.compactMap { ServiceKind.kind(for: $0) }
                return !postingKinds.isEmpty && postingKinds.contains(where: { filterOptions.selectedKinds.contains($0) })
            }
        }
        return results
    }
    
    private var orderedAvailableServices: [ServicePosting] {
        guard let selectedID = selectedServicePostingID,
              let index = filteredAvailableServices.firstIndex(where: { $0.id == selectedID }) else {
            return filteredAvailableServices
        }
        var ordered = filteredAvailableServices
        let selectedPosting = ordered.remove(at: index)
        ordered.insert(selectedPosting, at: 0)
        return ordered
    }
    
    private func region(for services: [ServicePosting]) -> MKCoordinateRegion {
        guard let first = services.first else {
            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: -23.55, longitude: -46.64), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        }
        let minLat = services.map { $0.coordinate.latitude }.min() ?? first.coordinate.latitude
        let maxLat = services.map { $0.coordinate.latitude }.max() ?? first.coordinate.latitude
        let minLon = services.map { $0.coordinate.longitude }.min() ?? first.coordinate.longitude
        let maxLon = services.map { $0.coordinate.longitude }.max() ?? first.coordinate.longitude
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        let span = MKCoordinateSpan(latitudeDelta: max(0.02, (maxLat - minLat) * 1.5), longitudeDelta: max(0.02, (maxLon - minLon) * 1.5))
        return MKCoordinateRegion(center: center, span: span)
    }
    
    private func binding(for service: UpcomingService) -> Binding<UpcomingService> {
        guard let index = upcomingServices.firstIndex(where: { $0.id == service.id }) else {
            return .constant(service)
        }
        return $upcomingServices[index]
    }
    
    private func selectPosting(_ posting: ServicePosting) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75, blendDuration: 0.2)) {
            selectedServicePostingID = posting.id
        }
    }
    
    private var homeBackgroundColor: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor.systemBackground : UIColor.systemGray6
        })
    }
}

private extension View {
    @ViewBuilder
    func onChangeCompat<Value: Equatable>(of value: Value, perform: @escaping (_ newValue: Value) -> Void) -> some View {
        if #available(iOS 17.0, *) {
            self.onChange(of: value) { _, newValue in
                perform(newValue)
            }
        } else {
            self.onChange(of: value, perform: perform)
        }
    }
}

struct ScheduledFilter {
    var minDate: Date?
    var maxDate: Date?
    var minPrice: String = ""
    var maxPrice: String = ""
    var status: ServiceStatus?

    var minPriceDecimal: Decimal? {
        CurrencyFormatter.decimal(from: minPrice) ?? Decimal(string: minPrice.replacingOccurrences(of: ",", with: "."))
    }

    var maxPriceDecimal: Decimal? {
        CurrencyFormatter.decimal(from: maxPrice) ?? Decimal(string: maxPrice.replacingOccurrences(of: ",", with: "."))
    }
}

struct ScheduledFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var filter: ScheduledFilter
    @State private var draft: ScheduledFilter

    init(filter: Binding<ScheduledFilter>) {
        self._filter = filter
        self._draft = State(initialValue: filter.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Preço") {
                    TextField("Preço mínimo", text: $draft.minPrice)
                        .keyboardType(.numbersAndPunctuation)
                    TextField("Preço máximo", text: $draft.maxPrice)
                        .keyboardType(.numbersAndPunctuation)
                }
                Section("Data") {
                    Toggle("Filtrar data inicial", isOn: Binding(
                        get: { draft.minDate != nil },
                        set: { draft.minDate = $0 ? (draft.minDate ?? Date()) : nil }
                    ))
                    if draft.minDate != nil {
                        DatePicker("Início", selection: Binding(
                            get: { draft.minDate ?? Date() },
                            set: { draft.minDate = $0 }
                        ), displayedComponents: .date)
                    }
                    Toggle("Filtrar data final", isOn: Binding(
                        get: { draft.maxDate != nil },
                        set: { draft.maxDate = $0 ? (draft.maxDate ?? Date()) : nil }
                    ))
                    if draft.maxDate != nil {
                        DatePicker("Fim", selection: Binding(
                            get: { draft.maxDate ?? Date() },
                            set: { draft.maxDate = $0 }
                        ), displayedComponents: .date)
                    }
                }
                Section("Status") {
                    Picker("Status", selection: Binding<ServiceStatus?>(
                        get: { draft.status },
                        set: { draft.status = $0 }
                    )) {
                        Text("Todos").tag(ServiceStatus?.none)
                        ForEach(ServiceStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(ServiceStatus?.some(status))
                        }
                    }
                }
                if draft.minDate != nil || draft.maxDate != nil || !draft.minPrice.trimmingCharacters(in: .whitespaces).isEmpty || !draft.maxPrice.trimmingCharacters(in: .whitespaces).isEmpty || draft.status != nil {
                    Section {
                        Button("Limpar filtros", role: .destructive) {
                            draft = ScheduledFilter()
                        }
                    }
                }
            }
            .navigationTitle("Filtrar serviços")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Aplicar") { filter = draft; dismiss() } }
            }
        }
    }
}

struct StatusButton: View {
    @Binding var status: ServiceStatus

    var body: some View {
        Menu {
            ForEach(ServiceStatus.allCases, id: \.self) { status in
                Button(action: {
                    self.status = status
                }) {
                    Text(status.rawValue)
                }
            }
        } label: {
            Text(status.rawValue)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(statusColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(statusColor.opacity(0.15))
                .clipShape(Capsule())
        }
    }
    
    var statusColor: Color {
        switch status {
        case .pending:
            return .yellow
        case .accepted:
            return Color.green.opacity(0.8)
        case .denied:
            return .red
        case .awaitingPayment:
            return .blue
        case .paid:
            return .teal
        case .finalized:
            return .gray
        }
    }
}

struct ServiceFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var filter: ServiceFilterOptions
    @State private var draft: ServiceFilterOptions
    @State private var showingSavedAddresses = false
    
    init(filter: Binding<ServiceFilterOptions>) {
        self._filter = filter
        self._draft = State(initialValue: filter.wrappedValue)
    }
    
    private let columns = [GridItem(.adaptive(minimum: 140), spacing: 12)]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Tipos de serviço") {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(ServiceKind.allCases) { kind in
                            let isSelected = draft.selectedKinds.contains(kind)
                            Button {
                                if isSelected {
                                    draft.selectedKinds.remove(kind)
                                } else {
                                    draft.selectedKinds.insert(kind)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: kind.iconName)
                                    Text(kind.displayName)
                                }
                                .font(.subheadline)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 10)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(isSelected ? Color.blue : Color.clear)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .stroke(Color.blue, lineWidth: isSelected ? 0 : 1)
                                        )
                                )
                                .foregroundColor(isSelected ? .white : .primary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
                Section("Endereço") {
                    TextField("Ex: Avenida Paulista", text: $draft.addressQuery)
                    if isCleaner {
                        Button {
                            showingSavedAddresses = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("Usar endereços salvos")
                            }
                        }
                        .disabled(authViewModel.cleanerCoverageAreas.isEmpty)
                    }
                }
                Section("Valor máximo") {
                    TextField("Ex: R$ 250", text: $draft.maxPrice)
                        .keyboardType(.numbersAndPunctuation)
                }
                if draft.hasActiveFilters {
                    Section {
                        Button("Limpar filtros", role: .destructive) {
                            draft = ServiceFilterOptions()
                        }
                    }
                }
            }
            .navigationTitle("Filtrar serviços")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Aplicar") {
                        filter = draft
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingSavedAddresses) {
            NavigationStack {
                List {
                    if authViewModel.cleanerCoverageAreas.isEmpty {
                        Text("Nenhum endereço salvo nas configurações.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(authViewModel.cleanerCoverageAreas, id: \.self) { area in
                            Button {
                                draft.addressQuery = area
                                showingSavedAddresses = false
                            } label: {
                                Text(area)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                .navigationTitle("Endereços salvos")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Fechar") { showingSavedAddresses = false }
                    }
                }
            }
        }
    }
    
    private var isCleaner: Bool {
        authViewModel.currentUserType == .cleaner
    }
}

struct ServiceFilterOptions: Equatable {
    var selectedKinds: Set<ServiceKind> = []
    var addressQuery: String = ""
    var maxPrice: String = ""
    
    var hasActiveFilters: Bool {
        !selectedKinds.isEmpty || !addressQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !maxPrice.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var maxPriceDecimal: Decimal? {
        let trimmed = maxPrice.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if let currency = CurrencyFormatter.decimal(from: trimmed) {
            return currency
        }
        let digitsOnly = trimmed.replacingOccurrences(of: "[^0-9,\\.]", with: "", options: .regularExpression)
        return Decimal(string: digitsOnly.replacingOccurrences(of: ",", with: "."))
    }
}

struct ServicePostingDetailView: View {
    let posting: ServicePosting
    @State private var region: MKCoordinateRegion
    @State private var responseStatus: ServiceStatus?
    
    init(posting: ServicePosting) {
        self.posting = posting
        _region = State(initialValue: MKCoordinateRegion(center: posting.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                addressSection
                servicesSection
                paymentSection
                notesSection
                attachmentsSection
                actionSection
                Spacer(minLength: 20)
            }
            .padding(.vertical)
        }
        .navigationTitle("Detalhes do Serviço")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerSection: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.gray.opacity(0.3))
            VStack(alignment: .leading, spacing: 8) {
                Text(posting.title)
                    .font(.title)
                    .fontWeight(.bold)
                Text("\(posting.date, style: .date) às \(posting.date, style: .time)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                ratingRow
            }
        }
        .padding(.horizontal)
    }
    
    private var addressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Endereço")
                .font(.headline)
            Text(posting.address)
                .font(.body)
            Map(position: .constant(.region(region)), interactionModes: [])
                .frame(height: 170)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(.horizontal)
    }
    
    private var servicesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Serviços")
                .font(.headline)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 8)], alignment: .leading, spacing: 8) {
                ForEach(posting.serviceTypes, id: \.self) { item in
                    HStack(spacing: 6) {
                        Image(systemName: ServiceKind.kind(for: item)?.iconName ?? "sparkles")
                        Text(item)
                    }
                    .font(.body)
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var paymentSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Pagamento")
                .font(.headline)
            Text(posting.formattedPrice)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.green)
        }
        .padding(.horizontal)
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Observações")
                .font(.headline)
            Text(posting.notes?.isEmpty == false ? posting.notes! : "Sem observações adicionais.")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
    
    private var actionSection: some View {
        VStack(spacing: 12) {
            if responseStatus == nil {
                HStack(spacing: 16) {
                    Button(role: .destructive) {
                        responseStatus = .denied
                    } label: {
                        Label("Negar", systemImage: "xmark.circle")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .background(Color.red)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    Button {
                        responseStatus = .accepted
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
            } else if let status = responseStatus {
                HStack {
                    Image(systemName: status == .accepted ? "checkmark.seal.fill" : "xmark.seal.fill")
                        .foregroundColor(status == .accepted ? .green : .red)
                    Text(status == .accepted ? "Serviço aceito" : "Serviço negado")
                        .font(.headline)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
        .padding(.horizontal)
    }
    
    private var ratingRow: some View {
        HStack(spacing: 4) {
            ForEach(0..<5) { index in
                Image(systemName: index < Int(posting.clientRating.rounded(.down)) ? "star.fill" : "star")
                    .foregroundColor(.yellow)
            }
            Text(String(format: "%.1f", posting.clientRating))
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var attachmentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Fotos do cliente")
                .font(.headline)
            if posting.attachments.isEmpty {
                Text("Nenhuma foto enviada.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(posting.attachments) { attachment in
                            attachmentCard(for: attachment)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private func attachmentCard(for attachment: CleaningAttachment) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if let image = attachment.image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140, height: 140)
                    .clipped()
                    .cornerRadius(16)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 140, height: 140)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            Text(attachment.description.isEmpty ? "Sem descrição" : attachment.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: 140, alignment: .leading)
        }
    }
}


#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
        .environmentObject(AppearanceSettings())
        .environmentObject(ServiceBoard())
}
