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
    private(set) var _pricelistItems: [PricelistItem]?
    var expirationDate: Date

    var checks: [Check]?

    var pricelistItems: [PricelistItem] {
        get {
            _pricelistItems ?? []
        }
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
            let discount = pricelistItem.price * discountRate
            return discount.rounded()
        } else { return 0 }
    }

    func addPricelistItems(_ pricelistItems: [PricelistItem]) {
        _pricelistItems?.append(contentsOf: pricelistItems)
    }
}
