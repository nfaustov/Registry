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

        static var descriptableCases: [AccountTransaction.Purpose] {
            [.laboratory, .equipment, .consumables, .building, .advertising, .other]
        }

        static var expenseCases: [AccountTransaction.Purpose] {
            [.salary, .agentFee, .laboratory, .equipment, .consumables, .building, .taxes, .advertising, .loan, .banking, .transferTo, .other]
        }
    }
}
