//
//  LabeledCurrency.swift
//  Registry
//
//  Created by Николай Фаустов on 15.05.2024.
//

import SwiftUI

struct LabeledCurrency: View {
    // MARK: - Dependencies

    private let titleKey: String
    private let value: Double
    private let unit: Bool

    // MARK: -

    init(_ titleKey: String, value: Double, unit: Bool = true) {
        self.titleKey = titleKey
        self.value = value
        self.unit = unit
    }

    var body: some View {
        LabeledContent(titleKey, value: valueString)
    }
}

#Preview {
    LabeledCurrency("Оплата", value: 313.00)
        .padding()
}

// MARK: - Calculations

private extension LabeledCurrency {
    var valueString: String {
        if value > floor(value) {
            return "\(value.formatted(.currency(code: unit ? "RUB" : "")))"
        } else {
            return "\(Int(value))".appending(unit ? " ₽" : "")
        }
    }
}
