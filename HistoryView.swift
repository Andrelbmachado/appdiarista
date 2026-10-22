//
//  HistoryView.swift
//  Diarista facil
//
//  Created by André Machado on 20/01/26.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var services: [UpcomingService] = MockDataService.shared.historyServices()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Serviços agendados")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    if upcomingSection.isEmpty {
                        Text("Não há serviços agendados no momento.")
                            .foregroundColor(.secondary)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(upcomingSection) { service in
                                NavigationLink(destination: UpcomingServiceDetailView(service: binding(for: service))) {
                                    ServiceStatusRow(service: service)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    Text("Histórico de serviços")
                        .font(.title2)
                        .fontWeight(.bold)
                    if historySection.isEmpty {
                        Text("Sem serviços finalizados ainda.")
                            .foregroundColor(.secondary)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(historySection) { service in
                                NavigationLink(destination: HistoryDetailView(service: service)) {
                                    HistoryCard(service: service)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var isCleaner: Bool {
        authViewModel.currentUserType == .cleaner
    }
    
    private var upcomingSection: [UpcomingService] {
        services.filter { $0.status == .accepted }
    }
    
    private var historySection: [UpcomingService] {
        services.filter { $0.status.isFinal || $0.status == .denied }
    }
    
    private func binding(for service: UpcomingService) -> Binding<UpcomingService> {
        guard let index = services.firstIndex(where: { $0.id == service.id }) else {
            return .constant(service)
        }
        return $services[index]
    }
}

private extension ServiceStatus {
    var isFinal: Bool { self == .finalized }
}

struct ServiceStatusRow: View {
    let service: UpcomingService
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(service.cleanerName)
                    .font(.system(size: 18, weight: .semibold))
                HStack(spacing: 4) {
                    Text("\(service.date, style: .date)")
                    Text("às \(service.date, style: .time)")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                Text(CurrencyFormatter.string(from: service.amount))
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            Spacer()
            StatusBadge(status: service.status)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var cardBackground: Color {
        colorScheme == .dark ? darkCardColor : .white
    }
    
    private var darkCardColor: Color {
        Color(red: 0.16, green: 0.18, blue: 0.22)
    }
}

struct HistoryCard: View {
    let service: UpcomingService
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(service.cleanerName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(cardTextColor)
                Text("\(service.date, style: .date) às \(service.date, style: .time)")
                    .font(.caption)
                    .foregroundColor(cardTextColor.opacity(0.7))
                Text(CurrencyFormatter.string(from: service.amount))
                    .font(.subheadline)
                    .foregroundColor(cardTextColor)
            }
            Spacer()
            StatusBadge(status: .finalized)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(cardBackground)
        .cornerRadius(14)
        .shadow(color: cardShadowColor, radius: 3, x: 0, y: 1)
    }
    
    private var cardBackground: Color {
        colorScheme == .dark ? Color(red: 0.16, green: 0.18, blue: 0.22) : .white
    }
    
    private var cardTextColor: Color {
        colorScheme == .dark ? Color(red: 0.95, green: 0.97, blue: 0.98) : .primary
    }
    
    private var cardShadowColor: Color {
        colorScheme == .dark ? Color.black.opacity(0.35) : Color.black.opacity(0.05)
    }
}

#Preview {
    HistoryView()
        .environmentObject(AuthViewModel())
        .environmentObject(AppearanceSettings())
}
