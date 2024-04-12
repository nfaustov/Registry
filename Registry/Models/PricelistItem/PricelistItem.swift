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
    public var archived: Bool = false
    public var salaryAmount: Double?
    public var treatmentPlans: [TreatmentPlan.Kind] = []

    public init(
        id: String,
        category: Department,
        title: String,
        price: Double,
        costPrice: Double = 0,
        salaryAmount: Double? = nil
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.price = price
        self.costPrice = costPrice
        archived = false
        self.salaryAmount = salaryAmount

        if category == .laboratory {
            treatmentPlans = [.pregnancy, .basic]
        } else {
            treatmentPlans = []
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id, category, title, price, costPrice, archived, salaryAmount, treatmentPlans
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.category = try container.decode(Department.self, forKey: .category)
        self.title = try container.decode(String.self, forKey: .title)
        self.price = try container.decode(Double.self, forKey: .price)
        self.costPrice = try container.decode(Double.self, forKey: .costPrice)
        self.archived = try container.decodeIfPresent(Bool.self, forKey: .archived) ?? false
        self.salaryAmount = try container.decodeIfPresent(Double.self, forKey: .salaryAmount)

        if let treatmentPlans = try container.decodeIfPresent([TreatmentPlan.Kind].self, forKey: .treatmentPlans) {
            self.treatmentPlans = treatmentPlans
        } else {
            if self.category == .laboratory {
                self.treatmentPlans = [.pregnancy, .basic]
            } else {
                self.treatmentPlans = []
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(category, forKey: .category)
        try container.encode(title, forKey: .title)
        try container.encode(price, forKey: .price)
        try container.encode(costPrice, forKey: .costPrice)
        try container.encode(archived, forKey: .archived)
        try container.encodeIfPresent(salaryAmount, forKey: .salaryAmount)
        try container.encode(treatmentPlans, forKey: .treatmentPlans)
    }

    public var treatmentPlanPrice: Double {
        if treatmentPlans.isEmpty {
            return price
        } else {
            return costPrice + 20
        }
    }
}

// MARK: - PricelistItem.Short

public extension PricelistItem {
    struct Short: Codable, Hashable, Identifiable {
        public let id: String
        public let category: Department
        public var title: String
        public var price: Double
        public var salaryAmount: Double?
    }

    var short: PricelistItem.Short {
        Short(
            id: id,
            category: category,
            title: title,
            price: price,
            salaryAmount: salaryAmount
        )
    }
}
