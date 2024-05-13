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

            if newValue.isEmpty {
                discount = 0
            }
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
        _services?.forEach {
            $0.charge(.make, for: \.performer)
            $0.charge(.make, for: \.agent)
        }
    }

    func cancelChargesForServices() {
        _services?.forEach {
            $0.charge(.cancel, for: \.performer)
            $0.charge(.cancel, for: \.agent)
        }
    }

    func makeRefund(_ refund: Refund) {
        self.refund = refund

        refund.services.forEach {
            $0.charge(.cancel, for: \.performer)
            $0.charge(.cancel, for: \.agent)
        }
    }
}
