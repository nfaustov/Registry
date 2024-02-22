//
//  Bill.swift
//  Registry
//
//  Created by Николай Фаустов on 20.02.2024.
//

import Foundation

public struct Bill: Codable, Hashable, Identifiable {
    public let id: UUID
    public var services: [RenderedService]
    public var discount: Double
    public var contract: Data?

    public var price: Double {
        services
            .map { $0.pricelistItem.price }
            .reduce(0.0, +)
    }

    public var totalPrice: Double {
        price - discount
    }

    public var discountRate: Double {
        guard price != 0 else { return 0 }
        return discount / price
    }

    public init(
        id: UUID = UUID(),
        services: [RenderedService],
        discount: Double = 0,
        contract: Data? = nil
    ) {
        self.id = id
        self.services = services
        self.discount = discount
        self.contract = contract
    }
}
