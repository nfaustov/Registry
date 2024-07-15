//
//  CurrencyTextKey.swift
//  Registry
//
//  Created by Николай Фаустов on 15.07.2024.
//

import SwiftUI

private struct CurrencyTextKey: EnvironmentKey {
    static let defaultValue: CurrencyValueAppearance = .integer
}

extension EnvironmentValues {
    var currencyAppearance: CurrencyValueAppearance {
        get { self[CurrencyTextKey.self] }
        set { self[CurrencyTextKey.self] = newValue }
    }
}

enum CurrencyValueAppearance {
    case integer
    case floating
}
