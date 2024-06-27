//
//  AccountTransaction.Purpose.swift
//  Registry
//
//  Created by Николай Фаустов on 14.06.2024.
//

import Foundation

extension AccountTransaction {
    enum Purpose: String, Codable, Hashable {
        case income = "Поступление"
        case dividends = "Дивиденды"
        case salary = "Заработная плата"
        case agentFee = "Агентские"
        case refund = "Возврат"
        case laboratory = "Лаборатория"
        case equipment = "Оборудование"
        case consumables = "Расходники"
        case building = "Помещение"
        case taxes = "Налоги"
        case advertising = "Реклама"
        case loan = "Кредит"
        case banking = "Банковские услуги"
        case transferTo = "Перевод на счет"
        case transferFrom = "Перевод со счета"
        case other = "Прочее"

        var expenseCategory: ExpenseCategory? {
            switch self {
            case .dividends:
                .dividends
            case .salary, .agentFee:
                .doctorPayout
            case .refund:
                .refund
            case .laboratory:
                .laboratory
            case .equipment:
                .equipment
            case .consumables:
                .consumables
            case .building:
                .building
            case .taxes:
                .taxes
            case .advertising:
                .advertising
            case .loan:
                .loan
            case .banking:
                .banking
            case .other:
                .other
            default: nil
            }
        }

        static var selectableExpenseCases: [AccountTransaction.Purpose] {
            [.salary, .agentFee, .laboratory, .equipment, .consumables, .building, .taxes, .advertising, .loan, .banking, .transferTo, .other]
        }
    }
}
