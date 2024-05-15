//
//  Refund.swift
//  Registry
//
//  Created by Николай Фаустов on 05.03.2024.
//

import Foundation
import SwiftData

@Model
final class Refund {
    let date: Date = Date.now
    @Relationship(inverse: \MedicalService.refund)
    private var _services: [MedicalService]?

    var services: [MedicalService] {
        get {
            _services ?? []
        }
        set {
            _services = newValue
        }
    }

    var check: Check?

    var price: Double {
        services
            .map { $0.pricelistItem.price }
            .reduce(0.0, +)
    }

    var totalAmount: Double {
        guard let check else { return 0 }
        return check.discountRate * price - price
    }

    init(services: [MedicalService]? = []) {
        self.date = .now
        self._services = services
    }
}
