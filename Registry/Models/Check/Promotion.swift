//
//  Promotion.swift
//  Registry
//
//  Created by Николай Фаустов on 05.06.2024.
//

import Foundation
import SwiftData

@Model
final class Promotion {
    let title: String
    let discountRate: Double
    @Relationship(inverse: \PricelistItem.promotions)
    let _pricelistItems: [PricelistItem]?
    var expirationDate: Date

    var pricelistItems: [PricelistItem] {
        _pricelistItems ?? []
    }

    init(
        title: String,
        discountRate: Double,
        pricelistItems: [PricelistItem]? = [],
        expirationDate: Date
    ) {
        self.title = title
        self.discountRate = discountRate
        self._pricelistItems = pricelistItems
        self.expirationDate = expirationDate
    }

    func discount(for pricelistItemID: String) -> Double {
        if let pricelistItem = pricelistItems.first(where: { $0.id == pricelistItemID }) {
            return pricelistItem.price * discountRate
        } else { return 0 }
    }
}
