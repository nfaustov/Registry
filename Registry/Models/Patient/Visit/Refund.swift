//
//  Refund.swift
//  Registry
//
//  Created by Николай Фаустов on 05.03.2024.
//

import Foundation

public struct Refund: Codable, Hashable, Identifiable {
    public let id: UUID
    public let date: Date
    public var services: [RenderedService]

    public var price: Double {
        services
            .map { $0.pricelistItem.price }
            .reduce(0.0, +)
    }

    public func totalAmount(discountRate rate: Double) -> Double {
        rate * price - price
    }

    public init(id: UUID = UUID(), services: [RenderedService]) {
        self.id = id
        self.date = .now
        self.services = services
    }
}
