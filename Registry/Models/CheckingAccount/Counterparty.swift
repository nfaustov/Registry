//
//  Counterparty.swift
//  Registry
//
//  Created by Николай Фаустов on 25.06.2024.
//

import Foundation
import SwiftData

@Model
final class Counterparty {
    let title: String
    let status: Counterparty.Status

    var transactions: [AccountTransaction]?

    var fullTitle: String {
        "\(status.rawValue) \(title)"
    }

    init(title: String, status: Counterparty.Status) {
        self.title = title
        self.status = status
    }
}

extension Counterparty {
    enum Status: String, Codable, Hashable, CaseIterable {
        case entity = "ООО"
        case entrepreneur = "ИП"
    }
}
