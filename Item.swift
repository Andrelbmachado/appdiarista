//
//  Item.swift
//  Diarista facil
//
//  Created by André Machado on 20/01/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
