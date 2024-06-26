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
        case transferTo = "Перевод на"
        case transferFrom = "Перевод с"
        case other = "Прочее"

        static var selectableExpenseCases: [AccountTransaction.Purpose] {
            [.salary, .agentFee, .laboratory, .equipment, .consumables, .building, .taxes, .advertising, .loan, .banking, .transferTo, .other]
        }
    }
}
