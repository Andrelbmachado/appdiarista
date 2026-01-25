import Foundation
import Combine
import MapKit

struct ServicePosting: Identifiable, Equatable {
    let id: UUID
    var title: String
    var address: String
    var date: Date
    var serviceTypes: [String]
    var notes: String?
    var price: Decimal
    var coordinate: CLLocationCoordinate2D
    var clientRating: Double
    var attachments: [CleaningAttachment]

    init(id: UUID = UUID(), title: String, address: String, date: Date, serviceTypes: [String], price: Decimal, coordinate: CLLocationCoordinate2D, notes: String? = nil, clientRating: Double = 4.5, attachments: [CleaningAttachment] = []) {
        self.id = id
        self.title = title
        self.address = address
        self.date = date
        self.serviceTypes = serviceTypes
        self.notes = notes
        self.price = price
        self.coordinate = coordinate
        self.clientRating = clientRating
        self.attachments = attachments
    }
    
    var formattedDate: String {
        date.formatted(date: .abbreviated, time: .omitted)
    }
    
    var formattedTime: String {
        date.formatted(date: .omitted, time: .shortened)
    }
    
    var formattedDateTime: String {
        date.formatted(date: .abbreviated, time: .shortened)
    }
    
    var formattedPrice: String {
        CurrencyFormatter.string(from: price)
    }
    
    var serviceSummary: String {
        serviceTypes.joined(separator: " • ")
    }
    
    func matches(query: String) -> Bool {
        let normalizedQuery = query.normalized
        guard !normalizedQuery.isEmpty else { return true }
        let searchableFields = [title, address, formattedDate, formattedTime, formattedDateTime, serviceSummary, formattedPrice]
        return searchableFields.map { $0.normalized }.contains { $0.contains(normalizedQuery) }
    }
}

final class ServiceBoard: ObservableObject {
    @Published var postings: [ServicePosting]
    
    init(postings: [ServicePosting] = ServiceBoard.sampleData) {
        self.postings = postings
    }
    
    func addPosting(_ posting: ServicePosting) {
        postings.insert(posting, at: 0)
    }
    
    private static var sampleData: [ServicePosting] {
        [
            ServicePosting(title: "Limpeza completa", address: "Av. Paulista, 1000", date: Date().addingTimeInterval(60 * 60 * 24), serviceTypes: ["Limpeza pesada", "Banheiros"], price: 220, coordinate: CLLocationCoordinate2D(latitude: -23.5617, longitude: -46.6559), notes: "Apartamento grande, trazer aspirador", clientRating: 4.8),
            ServicePosting(title: "Faxina de rotina", address: "Rua das Flores, 245", date: Date().addingTimeInterval(60 * 60 * 48), serviceTypes: ["Limpeza padrão"], price: 180, coordinate: CLLocationCoordinate2D(latitude: -23.5672, longitude: -46.648), notes: "Preferência por produtos sem cheiro", clientRating: 4.6),
            ServicePosting(title: "Pós-mudança", address: "Rua do Comércio, 18", date: Date().addingTimeInterval(60 * 60 * 72), serviceTypes: ["Limpeza pesada", "Janelas"], price: 260, coordinate: CLLocationCoordinate2D(latitude: -23.553, longitude: -46.639), notes: "Casa fechada por meses", clientRating: 4.9)
        ]
    }
}

extension ServicePosting {
    static func == (lhs: ServicePosting, rhs: ServicePosting) -> Bool {
        lhs.id == rhs.id
    }
}
