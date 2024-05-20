//
//  ChecksController.swift
//  Registry
//
//  Created by Николай Фаустов on 20.05.2024.
//

import Foundation
import SwiftData

@ModelActor
actor ChecksController {
    func getCorrelationsJSON() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(pricelistItemsCorrelations)
    }
}

private extension ChecksController {
    struct PricelistItemsCorrelation: Codable, Hashable {
        let item: PricelistItem.Snapshot
        let correlatedItem: PricelistItem.Snapshot
        var usage: Int
    }

    var pricelistItemsCorrelations: [PricelistItemsCorrelation] {
        var temp: [PricelistItemsCorrelation] = []

        for check in checks {
            if check.services.count > 1 {
                let items = check.services.map { $0.pricelistItem }
                for index in items.indices {
                    var correlatedItems = items
                    let itemKey = correlatedItems.remove(at: index)
                    let localCorrelations = correlatedItems.map { PricelistItemsCorrelation(item: itemKey, correlatedItem: $0, usage: 0) }
                    temp.append(contentsOf: localCorrelations)
                }
            }
        }

        let correlations = Dictionary(grouping: temp, by: { $0 })
            .filter { $1.count > 10 }
            .map { PricelistItemsCorrelation(item: $0.item, correlatedItem: $0.correlatedItem, usage: $1.count) }

        return correlations
    }

    var checks: [Check] {
        let descriptor = FetchDescriptor<Check>()

        if let fetchedChecks = try? modelContext.fetch(descriptor) {
            return fetchedChecks
        } else { return [] }
    }
}
