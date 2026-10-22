//
//  MockDataService.swift
//  Diarista facil
//
//  Camada de dados de exemplo atrás de protocolos.
//  Fase 0 do PLANO.md: isolar os dados mockados para que a Fase 1
//  troque apenas a implementação (ex.: Supabase) sem mexer nas telas.
//

import Foundation
import MapKit

// MARK: - Protocolos (contratos que o backend da Fase 1 implementará)

/// Autenticação e dados de perfil (endereços do cliente / áreas de cobertura da diarista).
protocol AuthService {
    func authenticate(email: String, password: String, userType: UserType) -> Bool
    func changePassword(for userType: UserType, oldPassword: String, newPassword: String) -> Bool
    func clientAddresses() -> [String]
    func cleanerCoverageAreas() -> [String]
}

/// Serviços publicados, próximos serviços e diaristas disponíveis.
protocol ServiceRepository {
    func servicePostings() -> [ServicePosting]
    func upcomingServices() -> [UpcomingService]
    func historyServices() -> [UpcomingService]
    func availableDiaristas() -> [Diarista]
}

/// Catálogo do marketplace.
protocol ProductRepository {
    func products() -> [MarketplaceProduct]
}

// MARK: - Implementação mock (em memória)

/// Fonte única dos dados de exemplo do protótipo.
///
/// Substituir por implementações reais na Fase 1 (Auth + Postgres + Storage),
/// mantendo os mesmos protocolos para não impactar as telas.
final class MockDataService: AuthService, ServiceRepository, ProductRepository {
    static let shared = MockDataService()

    private struct Credentials {
        let email: String
        var password: String
    }

    private var clientCredentials = Credentials(email: "cliente@diarista.com", password: "cliente123")
    private var cleanerCredentials = Credentials(email: "diarista@diarista.com", password: "diarista123")

    init() {}

    // MARK: AuthService

    func authenticate(email: String, password: String, userType: UserType) -> Bool {
        let expected = userType == .client ? clientCredentials : cleanerCredentials
        return email.lowercased() == expected.email.lowercased() && password == expected.password
    }

    func changePassword(for userType: UserType, oldPassword: String, newPassword: String) -> Bool {
        if userType == .client {
            guard oldPassword == clientCredentials.password else { return false }
            clientCredentials.password = newPassword
        } else {
            guard oldPassword == cleanerCredentials.password else { return false }
            cleanerCredentials.password = newPassword
        }
        return true
    }

    func clientAddresses() -> [String] {
        [
            "Rua das Flores, 123, Cidade, Estado",
            "Av. Paulista, 1500, São Paulo",
            "Rua do Mercado, 45, Centro"
        ]
    }

    func cleanerCoverageAreas() -> [String] {
        [
            "São Paulo e região",
            "Avenida Paulista",
            "Bairro Jardins"
        ]
    }

    // MARK: ServiceRepository

    func servicePostings() -> [ServicePosting] {
        [
            ServicePosting(title: "Limpeza completa", address: "Av. Paulista, 1000", date: Date().addingTimeInterval(60 * 60 * 24), serviceTypes: ["Limpeza pesada", "Banheiros"], price: 220, coordinate: CLLocationCoordinate2D(latitude: -23.5617, longitude: -46.6559), notes: "Apartamento grande, trazer aspirador", clientRating: 4.8),
            ServicePosting(title: "Faxina de rotina", address: "Rua das Flores, 245", date: Date().addingTimeInterval(60 * 60 * 48), serviceTypes: ["Limpeza padrão"], price: 180, coordinate: CLLocationCoordinate2D(latitude: -23.5672, longitude: -46.648), notes: "Preferência por produtos sem cheiro", clientRating: 4.6),
            ServicePosting(title: "Pós-mudança", address: "Rua do Comércio, 18", date: Date().addingTimeInterval(60 * 60 * 72), serviceTypes: ["Limpeza pesada", "Janelas"], price: 260, coordinate: CLLocationCoordinate2D(latitude: -23.553, longitude: -46.639), notes: "Casa fechada por meses", clientRating: 4.9)
        ]
    }

    func upcomingServices() -> [UpcomingService] {
        [
            UpcomingService(cleanerName: "Maria Silva", date: Date().addingTimeInterval(86400 * 2), status: .pending, amount: 180, clientRating: 4.7, notes: "Apartamento pequeno, trazer pano de chão."),
            UpcomingService(cleanerName: "Ana Costa", date: Date().addingTimeInterval(86400 * 9), status: .accepted, amount: 220, clientRating: 4.9, notes: "Preferência por produtos sem cheiro."),
            UpcomingService(cleanerName: "Joana Pereira", date: Date().addingTimeInterval(86400 * 5), status: .finalized, amount: 150, proofImageData: nil, clientRating: 4.5, notes: "Casa com pets.")
        ]
    }

    func historyServices() -> [UpcomingService] {
        [
            UpcomingService(cleanerName: "Maria Silva", date: Date().addingTimeInterval(86400 * 2), status: .pending, amount: 180, clientRating: 4.8, notes: "Levar aspirador."),
            UpcomingService(cleanerName: "Ana Costa", date: Date().addingTimeInterval(86400 * 5), status: .accepted, amount: 220, clientRating: 4.6, notes: "Casa com criança pequena."),
            UpcomingService(cleanerName: "Joana Pereira", date: Date().addingTimeInterval(86400 * 3), status: .denied, amount: 150, clientRating: 4.2, notes: "Prefere horário vespertino."),
            UpcomingService(cleanerName: "Mariana Lopes", date: Date().addingTimeInterval(-86400 * 1), status: .finalized, amount: 200, clientRating: 4.9, notes: "Serviço concluído sem observações."),
            UpcomingService(cleanerName: "Selma Araújo", date: Date().addingTimeInterval(-86400 * 4), status: .finalized, amount: 170, clientRating: 4.5, notes: "Precisa levar produtos próprios.")
        ]
    }

    func availableDiaristas() -> [Diarista] {
        [
            Diarista(name: "Maria Silva", age: 34, rating: 4.8, services: ["Limpeza Padrão", "Passar Roupa"], avatar: "person.fill", price: 180, coverageAreas: ["Rua das Flores", "Av. Paulista"]),
            Diarista(name: "Joana Pereira", age: 28, rating: 4.5, services: ["Limpeza Pesada", "Limpeza de Vidros"], avatar: "person.crop.circle.fill", price: 230, coverageAreas: ["Centro", "Avenida Paulista"]),
            Diarista(name: "Ana Costa", age: 42, rating: 5.0, services: ["Todos os serviços"], avatar: "person.crop.square.fill", price: 200, coverageAreas: ["Rua do Mercado", "Bairro Jardins"])
        ]
    }

    // MARK: ProductRepository

    func products() -> [MarketplaceProduct] {
        MarketplaceProduct.catalog
    }
}
