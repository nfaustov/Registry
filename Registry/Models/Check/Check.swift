//
//  Bill.swift
//  Registry
//
//  Created by Николай Фаустов on 20.02.2024.
//

import Foundation
import SwiftData

@Model
final class Check {
    @Relationship(deleteRule: .cascade, inverse: \MedicalService.check)
    private var _services: [MedicalService]?
    var discount: Double = 0
    @Relationship(deleteRule: .cascade, inverse: \Refund.check)
    private(set) var refund: Refund? = nil

    var appointments: [PatientAppointment]?
    var payment: Payment?

    var services: [MedicalService] {
        get {
            _services ?? []
        }
        set {
            _services = newValue
        }
    }

    var price: Double {
        services
            .map { $0.pricelistItem.price }
            .reduce(0.0, +)
    }

    var totalPrice: Double {
        price - discount
    }

    var discountRate: Double {
        guard price != 0 else { return 0 }
        return discount / price
    }

    init(
        services: [MedicalService]? = [],
        discount: Double = 0,
        refund: Refund? = nil
    ) {
        self._services = services
        self.discount = discount
        self.refund = refund
    }

    func makeChargesForServices() {
        _services?.forEach { $0.makeCharges() }
    }

    func cancelChargesForServices() {
        _services?.forEach { $0.cancelCharges() }
    }

    func makeRefund(_ refund: Refund) {
        self.refund = refund
        refund.cancelChargesForServices()
    }
}
