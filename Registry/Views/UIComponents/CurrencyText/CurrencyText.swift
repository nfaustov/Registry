//
//  CurrencyText.swift
//  Registry
//
//  Created by Николай Фаустов on 08.05.2024.
//

import SwiftUI

struct CurrencyText: View {
    // MARK: - Dependencies

    let value: Double
    let unit: Bool

    // MARK: -

    init(_ value: Double, unit: Bool = true) {
        self.value = value
        self.unit = unit
    }

    var body: some View {
        Text(valueString)
    }
}

#Preview {
    CurrencyText(313.5, unit: false)
}

// MARK: - Calculations

private extension CurrencyText {
    var valueString: String {
        if value > floor(value) {
            return "\(value.formatted(.currency(code: unit ? "RUB" : "")))"
        } else {
            return "\(Int(value))".appending(unit ? " ₽" : "")
        }
    }
}
