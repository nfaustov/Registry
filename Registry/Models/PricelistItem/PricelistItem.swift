//
//  PricelistItem.swift
//  Registry
//
//  Created by Николай Фаустов on 17.01.2024.
//

import Foundation
import SwiftData

@Model
final class PricelistItem: Codable {
    let id: String = ""
    var category: Department = Department.gynecology
    var title: String = ""
    var price: Double = Double.zero
    var costPrice: Double = Double.zero
    var archived: Bool = false
    var fixedSalary: Double? = nil
    var fixedAgentFee: Double? = nil
    var treatmentPlans: [TreatmentPlan.Kind] = []

    var doctors: [Doctor]?
    var promotions: [Promotion]?

    init(
        id: String,
        category: Department,
        title: String,
        price: Double,
        costPrice: Double = 0,
        fixedSalary: Double? = nil,
        fixedAgentFee: Double? = nil
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.price = price
        self.costPrice = costPrice
        archived = false
        self.fixedSalary = fixedSalary
        self.fixedAgentFee = fixedAgentFee

        if category == .laboratory {
            treatmentPlans = [.pregnancy, .basic]
        } else {
            treatmentPlans = []
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id, category, title, price, costPrice, archived, fixedSalary, fixedAgentFee, treatmentPlans
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.category = try container.decode(Department.self, forKey: .category)
        self.title = try container.decode(String.self, forKey: .title)
        self.price = try container.decode(Double.self, forKey: .price)
        self.costPrice = try container.decode(Double.self, forKey: .costPrice)
        self.archived = try container.decodeIfPresent(Bool.self, forKey: .archived) ?? false
        self.fixedSalary = try container.decodeIfPresent(Double.self, forKey: .fixedSalary)
        self.fixedAgentFee = try container.decodeIfPresent(Double.self, forKey: .fixedAgentFee)

        if let treatmentPlans = try container.decodeIfPresent([TreatmentPlan.Kind].self, forKey: .treatmentPlans) {
            self.treatmentPlans = treatmentPlans
        } else {
            if self.category == .laboratory {
                self.treatmentPlans = TreatmentPlan.Kind.allCases
            } else {
                self.treatmentPlans = []
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(category, forKey: .category)
        try container.encode(title, forKey: .title)
        try container.encode(price, forKey: .price)
        try container.encode(costPrice, forKey: .costPrice)
        try container.encode(archived, forKey: .archived)
        try container.encodeIfPresent(fixedSalary, forKey: .fixedSalary)
        try container.encodeIfPresent(fixedAgentFee, forKey: .fixedAgentFee)
        try container.encode(treatmentPlans, forKey: .treatmentPlans)
    }

    func treatmentPlanPrice(_ treatmentPlan: TreatmentPlan.Kind) -> Double? {
        if treatmentPlans.contains(treatmentPlan) {
            if treatmentPlan.isPregnancyAI {
                return 0
            } else {
                var estimatedPrice = Double.zero

                if category == .laboratory || category == .procedure {
                    estimatedPrice = costPrice + 20
                } else {
                    estimatedPrice = costPrice + 50
                }

                return estimatedPrice >= price ? price : estimatedPrice
            }
        } else { return nil }
    }
}
