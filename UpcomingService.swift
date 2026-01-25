//
//  UpcomingService.swift
//  Diarista facil
//
//  Created by André Machado on 20/01/26.
//

import Foundation

enum ServiceStatus: String, CaseIterable {
    case pending = "Pendente"
    case accepted = "Aceito"
    case denied = "Negado"
    case awaitingPayment = "Pagamento Solicitado"
    case paid = "Pago"
    case finalized = "Finalizado"
}

struct UpcomingService: Identifiable {
    let id = UUID()
    let cleanerName: String
    var date: Date
    var endDate: Date
    var status: ServiceStatus
    var amount: Decimal
    var proofImageData: Data?
    var clientRating: Double
    var notes: String

    init(cleanerName: String, date: Date, endDate: Date? = nil, status: ServiceStatus, amount: Decimal = 150, proofImageData: Data? = nil, clientRating: Double = 4.5, notes: String = "") {
        self.cleanerName = cleanerName
        self.date = date
        if let endDate {
            self.endDate = max(endDate, date)
        } else {
            self.endDate = max(date.addingTimeInterval(2 * 3600), date)
        }
        self.status = status
        self.amount = amount
        self.proofImageData = proofImageData
        self.clientRating = clientRating
        self.notes = notes
    }
}
