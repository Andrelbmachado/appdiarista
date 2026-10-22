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

    init(repository: ServiceRepository = MockDataService.shared) {
        self.postings = repository.servicePostings()
    }

    init(postings: [ServicePosting]) {
        self.postings = postings
    }

    func addPosting(_ posting: ServicePosting) {
        postings.insert(posting, at: 0)
    }
}

extension ServicePosting {
    static func == (lhs: ServicePosting, rhs: ServicePosting) -> Bool {
        lhs.id == rhs.id
    }
}
