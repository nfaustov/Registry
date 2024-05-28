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
    var pricelistItemsCorrelations: [PricelistItemsCorrelation] {
        var temp: [PricelistItemsCorrelation] = []

        for check in checks {
            if check.services.count > 1 {
                let items = check.services.map { $0.pricelistItem }
                for index in items.indices {
                    var correlatedItems = items
                    let itemKey = correlatedItems.remove(at: index)
                    let localCorrelations = correlatedItems.map { PricelistItemsCorrelation(itemID: itemKey.id, correlatedItemID: $0.id, usage: 0) }
                    temp.append(contentsOf: localCorrelations)
                }
            }
        }

        let correlations = Dictionary(grouping: temp, by: { $0 })
            .filter { $1.count > 5 }
            .map { PricelistItemsCorrelation(itemID: $0.itemID, correlatedItemID: $0.correlatedItemID, usage: $1.count) }

        return correlations
    }
}

private extension ChecksController {
    var checks: [Check] {
        let descriptor = FetchDescriptor<Check>()

        if let fetchedChecks = try? modelContext.fetch(descriptor) {
            return fetchedChecks
        } else { return [] }
    }
}

struct PricelistItemsCorrelation: Codable, Hashable {
    let itemID: String
    let correlatedItemID: String
    var usage: Int
}
