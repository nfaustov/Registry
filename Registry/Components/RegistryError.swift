//
//  RegistryError.swift
//  Registry
//
//  Created by Николай Фаустов on 04.07.2024.
//

import Foundation

enum RegistryError: LocalizedError {
    case closedReport

    var errorDescription: String? {
        switch self {
        case .closedReport:
            "Не удалось провести платеж"
        }
    }

    var message: String {
        switch self {
        case .closedReport:
            "Смена уже закрыта"
        }
    }
}
