//
//  PaymentPurpose.swift
//  Registry
//
//  Created by Николай Фаустов on 21.02.2024.
//

import Foundation

enum PaymentPurpose: String, Codable, Hashable {
    case collection = "Инкассация"
    case doctorPayout = "Выплата"
    case medicalServices = "Оплата услуг"
    case refund = "Возврат"
    case toBalance = "Пополнение баланса"
    case fromBalance = "Списание с баланса"
    case equipment = "Оборудование"
    case consumables = "Расходники"
    case building = "Помещение"

    var expenseCategory: ExpenseCategory? {
        switch self {
        case .doctorPayout:
            .doctorPayout
        case .refund:
            .refund
        case .equipment:
            .equipment
        case .consumables:
            .consumables
        case .building:
            .building
        default: nil
        }
    }

    static var userSelectableCases: [PaymentPurpose] {
        [.collection, .equipment, .consumables, .building]
    }

    func convertToAccountTransactionPurpose() -> AccountTransaction.Purpose? {
        switch self {
        case .doctorPayout:
            .salary
        case .refund:
            .refund
        case .equipment:
            .equipment
        case .consumables:
            .consumables
        case .building:
            .building
        default:
            nil
        }
    }
}
