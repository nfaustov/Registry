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

    // MARK: -

    init(_ value: Double) {
        self.value = value
    }

    var body: some View {
        if value > floor(value) {
            Text(value, format: .currency(code: "RUB"))
        } else {
            Text("\(Int(value)) ₽")
        }
    }
}

#Preview {
    CurrencyText(313.5)
}
