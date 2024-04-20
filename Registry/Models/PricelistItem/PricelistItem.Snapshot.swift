//
//  PricelistItem.Snapshot.swift
//  Registry
//
//  Created by Николай Фаустов on 18.04.2024.
//

import Foundation

extension RegistrySchemaV2.PricelistItem {
    struct Snapshot: Codable, Hashable, Identifiable {
        var id: String = ""
        var category: Department = .gynecology
        var title: String = ""
        var price: Double = 0
        var fixedSalary: Double?
        var fixedAgentFee: Double?

        init(
            id: String = "",
            category: Department = .gynecology,
            title: String = "",
            price: Double = 0,
            fixedSalary: Double? = nil,
            fixedAgentFee: Double? = nil
        ) {
            self.id = id
            self.category = category
            self.title = title
            self.price = price
            self.fixedSalary = fixedSalary
            self.fixedAgentFee = fixedAgentFee
        }
    }

    var snapshot: RegistrySchemaV2.PricelistItem.Snapshot {
        Snapshot(
            id: id,
            category: category,
            title: title,
            price: price,
            fixedSalary: fixedSalary,
            fixedAgentFee: fixedAgentFee
        )
    }
}

extension RegistrySchemaV3.PricelistItem {
    struct Snapshot: Codable, Hashable, Identifiable {
        let id: String
        let category: Department
        var title: String
        var price: Double
        var fixedSalary: Double?
        var fixedAgentFee: Double?
    }

    var snapshot: RegistrySchemaV3.PricelistItem.Snapshot {
        Snapshot(
            id: id,
            category: category,
            title: title,
            price: price,
            fixedSalary: fixedSalary,
            fixedAgentFee: fixedAgentFee
        )
    }
}
