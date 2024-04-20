//
//  Payment.Method.swift
//  Registry
//
//  Created by Николай Фаустов on 21.02.2024.
//

import Foundation

extension RegistrySchemaV3.Payment {
    struct Method: Codable, Hashable {
        public var type: PaymentType
        public var value: Double

        public init(_ type: PaymentType, value: Double) {
            self.type = type
            self.value = value
        }
    }
}

enum PaymentType: String, Codable, Hashable, CaseIterable {
    case cash = "Наличные"
    case bank = "Терминал"
    case card = "Карта"
}
