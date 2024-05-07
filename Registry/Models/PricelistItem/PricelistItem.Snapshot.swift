//
//  PricelistItem.Snapshot.swift
//  Registry
//
//  Created by Николай Фаустов on 18.04.2024.
//

import Foundation

extension PricelistItem {
    struct Snapshot: Codable, Hashable, Identifiable {
        let id: String
        let category: Department
        let title: String
        let price: Double
        var fixedSalary: Double?
        var fixedAgentFee: Double?
    }

    var snapshot: PricelistItem.Snapshot {
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
