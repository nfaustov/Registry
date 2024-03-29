//
//  MessageError.swift
//  Registry
//
//  Created by Николай Фаустов on 28.03.2024.
//

import Foundation

enum MessageError: LocalizedError {
    case phoneError

    var errorDescription: String? {
        switch self {
        case .phoneError:
            "Не найден номер телефона для отправки смс."
        }
    }
}
