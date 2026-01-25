//
//  Diarista.swift
//  Diarista facil
//
//  Created by André Machado on 20/01/26.
//

import Foundation

struct Diarista: Identifiable {
    let id = UUID()
    let name: String
    let age: Int
    let rating: Double
    let services: [String]
    let avatar: String // System image name for avatar
    let price: Decimal
    let coverageAreas: [String]
}
