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
    let terms: String
    let discountRate: Double
    @Relationship(inverse: \PricelistItem.promotions)
    private var _pricelistItems: [PricelistItem]?
    var expirationDate: Date

    var checks: [Check]?

    var pricelistItems: [PricelistItem] {
        get {
            _pricelistItems ?? []
        }
    }

    init(
        title: String,
        terms: String,
        discountRate: Double,
        pricelistItems: [PricelistItem]? = [],
        expirationDate: Date
    ) {
        self.title = title
        self.terms = terms
        self.discountRate = discountRate
        self._pricelistItems = pricelistItems
        self.expirationDate = expirationDate
    }

    func addPricelistItems(_ pricelistItems: [PricelistItem]) {
        _pricelistItems?.append(contentsOf: pricelistItems)
    }
}
