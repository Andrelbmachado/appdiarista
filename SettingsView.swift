import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var appearance: AppearanceSettings
    
    @State private var username = "André Machado"
    @State private var phoneNumber = "123-456-7890"
    @State private var newPassword = ""
    @State private var address = "Rua das Flores, 123, Cidade, Estado"
    @State private var serviceOfferings: [ServiceOffering] = [
        ServiceOffering(type: .standard, price: "R$ 180"),
        ServiceOffering(type: .heavy, price: "R$ 220"),
        ServiceOffering(type: .windows, price: "R$ 150")
    ]
    @State private var schedule = "Seg-Sex, 8h às 18h"
    @State private var clientLocation = "Rua das Flores, 123, Cidade, Estado"
    @State private var showingPhotoPicker = false
    @State private var serviceStartTime = Date()
    @State private var serviceEndTime = Calendar.current.date(byAdding: .hour, value: 4, to: Date()) ?? Date()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    HStack {
                        Text("Conta")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                        NavigationLink {
                            AccountPreferencesView(
                                username: $username,
                                phoneNumber: $phoneNumber,
                                newPassword: $newPassword,
                                address: $address,
                                serviceOfferings: $serviceOfferings,
                                schedule: $schedule,
                                coverageAreas: $authViewModel.cleanerCoverageAreas,
                                clientLocation: $clientLocation,
                                serviceStartTime: $serviceStartTime,
                                serviceEndTime: $serviceEndTime,
                                isCleaner: isCleaner,
                                userType: authViewModel.currentUserType ?? .client
                            )
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.title3)
                                .padding(10)
                                .background(.thinMaterial, in: Circle())
                                .overlay(
                                    Circle().stroke(Color.white.opacity(0.4), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal)
                    avatarSection
                    Text(username)
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                    Text(roleDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 16)
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                logoutButton
                    .padding(.horizontal)
                    .padding(.vertical, 16)
                    .background(Color(.systemGray6))
            }
        }
    }
    
    private var avatarSection: some View {
        Button(action: { showingPhotoPicker = true }) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
                .foregroundColor(.gray.opacity(0.3))
                .overlay(
                    Circle()
                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                        .foregroundColor(.white.opacity(0.6))
                )
        }
        .disabled(true)
    }
    
    private var logoutButton: some View {
        Button(role: .destructive) {
            authViewModel.isLoggedIn = false
            authViewModel.currentUserType = nil
            authViewModel.loginError = nil
        } label: {
            Label("Sair", systemImage: "rectangle.portrait.and.arrow.right")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.12))
                .foregroundColor(.red)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }
    
    private var roleDescription: String {
        switch authViewModel.currentUserType {
        case .cleaner: return "Diarista"
        case .client: return "Cliente"
        case .none: return ""
        }
    }
    
    private var isCleaner: Bool {
        authViewModel.currentUserType == .cleaner
    }
}

struct AccountPreferencesView: View {
    @Binding var username: String
    @Binding var phoneNumber: String
    @Binding var newPassword: String
    @Binding var address: String
    @Binding var serviceOfferings: [ServiceOffering]
    @Binding var schedule: String
    @Binding var coverageAreas: [String]
    @Binding var clientLocation: String
    @Binding var serviceStartTime: Date
    @Binding var serviceEndTime: Date
    let isCleaner: Bool
    let userType: UserType
    
    @EnvironmentObject var appearance: AppearanceSettings
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingPhotoPicker = false
    @State private var showingAddAddressSheet = false
    @State private var showingCoverageSheet = false
    @State private var newAddressText = ""
    @State private var newCoverageText = ""

    private let textSizes: [DynamicTypeSize] = [.small, .medium, .large, .xLarge, .xxLarge, .xxxLarge]
    
    var body: some View {
        Form {
            Section("Perfil") {
                TextField("Nome", text: $username)
                TextField("Telefone", text: $phoneNumber)
                Button {
                    showingPhotoPicker = true
                } label: {
                    Label("Editar foto do perfil", systemImage: "camera.fill")
                }
                NavigationLink("Alterar senha") {
                    ChangePasswordView(userType: userType)
                }
            }
            
            if isCleaner {
                Section {
                    ForEach(serviceOfferings) { service in
                        serviceOfferingRow(service: binding(for: service))
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    removeService(service)
                                } label: {
                                    Label("Excluir", systemImage: "trash")
                                }
                            }
                    }
                    if serviceOfferings.isEmpty {
                        Text("Adicione seus serviços para que os clientes conheçam seu trabalho.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    HStack {
                        Text("Serviços oferecidos")
                        Spacer()
                        Button(action: addService) {
                            Label("Adicionar serviço", systemImage: "plus.circle.fill")
                                .labelStyle(.iconOnly)
                                .font(.title3)
                        }
                        .buttonStyle(.plain)
                    }
                }
                Section {
                    if authViewModel.cleanerCoverageAreas.isEmpty {
                        Text("Adicione as regiões que você atende.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(authViewModel.cleanerCoverageAreas, id: \.self) { area in
                            Text(area)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        authViewModel.cleanerCoverageAreas.removeAll { $0 == area }
                                    } label: {
                                        Label("Apagar", systemImage: "trash")
                                    }
                                }
                        }
                    }
                } header: {
                    HStack {
                        Text("Áreas de cobertura")
                        Spacer()
                        Button {
                            newCoverageText = ""
                            showingCoverageSheet = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                        .buttonStyle(.plain)
                    }
                }
                Section("Horários de atendimento") {
                    HStack(spacing: 12) {
                        schedulePicker(title: "Início", date: $serviceStartTime)
                        schedulePicker(title: "Término", date: $serviceEndTime)
                    }
                }
            } else {
                Section {
                    if authViewModel.clientAddresses.isEmpty {
                        Text("Nenhum endereço salvo. Adicione um novo para começar.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(authViewModel.clientAddresses, id: \.self) { savedAddress in
                            Text(savedAddress)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        if let index = authViewModel.clientAddresses.firstIndex(of: savedAddress) {
                                            authViewModel.clientAddresses.remove(at: index)
                                        }
                                    } label: {
                                        Label("Apagar", systemImage: "trash")
                                    }
                                }
                        }
                    }
                } header: {
                    HStack {
                        Text("Localização do cliente")
                        Spacer()
                        Button {
                            showingAddAddressSheet = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                    }
                }
            }
            
            Section("Aparência") {
                Picker("Modo de exibição", selection: $appearance.mode) {
                    ForEach(AppearanceSettings.Mode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                Picker("Tamanho do texto", selection: $appearance.dynamicType) {
                    ForEach(textSizes, id: \.self) { size in
                        Text(label(for: size)).tag(size)
                    }
                }
            }
        }
        .navigationTitle("Configurações")
        .sheet(isPresented: $showingAddAddressSheet) {
            NavigationStack {
                Form {
                    TextField("Novo endereço", text: $newAddressText)
                }
                .navigationTitle("Adicionar endereço")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancelar") { showingAddAddressSheet = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Salvar") {
                            let trimmed = newAddressText.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmed.isEmpty {
                                authViewModel.clientAddresses.append(trimmed)
                            }
                            newAddressText = ""
                            showingAddAddressSheet = false
                        }
                        .disabled(newAddressText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
        .sheet(isPresented: $showingCoverageSheet) {
            NavigationStack {
                Form {
                    TextField("Área atendida", text: $newCoverageText)
                }
                .navigationTitle("Adicionar área")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancelar") { showingCoverageSheet = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Salvar") {
                            let trimmed = newCoverageText.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmed.isEmpty {
                                authViewModel.cleanerCoverageAreas.append(trimmed)
                            }
                            newCoverageText = ""
                            showingCoverageSheet = false
                        }
                        .disabled(newCoverageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
        }
        }
    }
    
    private func binding(for service: ServiceOffering) -> Binding<ServiceOffering> {
        guard let index = serviceOfferings.firstIndex(where: { $0.id == service.id }) else {
            return .constant(service)
        }
        return $serviceOfferings[index]
    }

    private func serviceOfferingRow(service: Binding<ServiceOffering>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Picker(selection: service.type) {
                ForEach(ServiceKind.allCases) { kind in
                    Label(kind.displayName, systemImage: kind.iconName)
                        .tag(kind)
                }
            } label: {
                HStack {
                    Image(systemName: service.wrappedValue.type.iconName)
                    Text(service.wrappedValue.type.displayName)
                }
                .font(.headline)
            }
            .pickerStyle(.navigationLink)

            TextField("Preço", text: service.price)
                .keyboardType(.numbersAndPunctuation)
                .textFieldStyle(.roundedBorder)
        }
        .padding(.vertical, 4)
    }

    private func addService() {
        withAnimation {
            serviceOfferings.append(ServiceOffering(type: .standard, price: ""))
        }
    }

    private func removeService(_ service: ServiceOffering) {
        withAnimation {
            serviceOfferings.removeAll { $0.id == service.id }
        }
    }
    
    private func schedulePicker(title: String, date: Binding<Date>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            DatePicker("", selection: date, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .datePickerStyle(.compact)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
        }
        .frame(maxWidth: .infinity)
    }

    private func label(for size: DynamicTypeSize) -> String {
        switch size {
        case .small: return "Pequeno"
        case .medium: return "Médio"
        case .large: return "Padrão"
        case .xLarge: return "Grande"
        case .xxLarge: return "Muito grande"
        case .xxxLarge: return "Enorme"
        default: return "Custom"
        }
    }
}

struct ChangePasswordView: View {
    let userType: UserType
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmation = ""
    @State private var alertMessage: String?
    
    var body: some View {
        Form {
            Section("Senha atual") {
                SecureField("Senha atual", text: $currentPassword)
            }
            Section("Nova senha") {
                SecureField("Nova senha", text: $newPassword)
                SecureField("Confirmar nova senha", text: $confirmation)
            }
            Section {
                Button("Atualizar senha") {
                    updatePassword()
                }
                .disabled(newPassword.isEmpty || newPassword != confirmation)
            }
        }
        .navigationTitle("Alterar senha")
        .alert(alertMessage ?? "", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        }
    }
    
    private func updatePassword() {
        guard newPassword == confirmation else {
            alertMessage = "As senhas não coincidem."
            return
        }
        if authViewModel.changePassword(for: userType, oldPassword: currentPassword, newPassword: newPassword) {
            alertMessage = "Senha alterada com sucesso!"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        } else {
            alertMessage = authViewModel.loginError ?? "Não foi possível alterar a senha."
        }
    }
}

struct ServiceOffering: Identifiable, Equatable {
    let id: UUID
    var type: ServiceKind
    var price: String
    
    init(id: UUID = UUID(), type: ServiceKind, price: String) {
        self.id = id
        self.type = type
        self.price = price
    }
}

enum ServiceKind: String, CaseIterable, Identifiable, Hashable {
    case standard
    case heavy
    case laundry
    case windows
    case bathrooms
    case fullHouse
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .standard: return "Limpeza padrão"
        case .heavy: return "Limpeza pesada"
        case .laundry: return "Passar roupa"
        case .windows: return "Limpeza de vidros"
        case .bathrooms: return "Banheiros"
        case .fullHouse: return "Faxina completa"
        }
    }
    
    var iconName: String {
        switch self {
        case .standard: return "sparkles"
        case .heavy: return "hammer"
        case .laundry: return "tshirt"
        case .windows: return "drop"
        case .bathrooms: return "shower"
        case .fullHouse: return "house.fill"
        }
    }
    
    func matches(serviceName: String) -> Bool {
        let lower = serviceName.lowercased()
        switch self {
        case .standard: return lower.contains("padr")
        case .heavy: return lower.contains("pesad")
        case .laundry: return lower.contains("roup")
        case .windows: return lower.contains("vidr")
        case .bathrooms: return lower.contains("banh")
        case .fullHouse: return lower.contains("faxina") || lower.contains("complet")
        }
    }
    
    static func kind(for serviceName: String) -> ServiceKind? {
        ServiceKind.allCases.first { $0.matches(serviceName: serviceName) }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
        .environmentObject(AppearanceSettings())
}
