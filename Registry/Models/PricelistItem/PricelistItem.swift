//
//  PricelistItem.swift
//  Registry
//
//  Created by Николай Фаустов on 17.01.2024.
//

import Foundation
import SwiftData

@Model
public final class PricelistItem: Codable {
    public let id: String = ""
    public var category: Department = Department.gynecology
    public var title: String = ""
    public var price: Double = Double.zero
    public var costPrice: Double = Double.zero

    public init(
        id: String,
        category: Department,
        title: String,
        price: Double,
        costPrice: Double = 0
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.price = price
        self.costPrice = costPrice
    }

    enum CodingKeys: CodingKey {
        case id, category, title, price, costPrice
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.category = try container.decode(Department.self, forKey: .category)
        self.title = try container.decode(String.self, forKey: .title)
        self.price = try container.decode(Double.self, forKey: .price)
        self.costPrice = try container.decode(Double.self, forKey: .costPrice)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(category, forKey: .category)
        try container.encode(title, forKey: .title)
        try container.encode(price, forKey: .price)
        try container.encode(costPrice, forKey: .costPrice)
    }
}
