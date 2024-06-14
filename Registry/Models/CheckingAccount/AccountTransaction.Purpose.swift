//
//  AccountTransaction.Purpose.swift
//  Registry
//
//  Created by Николай Фаустов on 14.06.2024.
//

import Foundation

extension AccountTransaction {
    enum Purpose: Codable, Hashable {
        case income
        case salary(String = "")
        case agentFee(String = "")
        case laboratory(String = "")
        case equipment(String = "")
        case consumables(String = "")
        case building(String = "")
        case taxes
        case advertising(String = "")
        case loan
        case banking
        case transferTo(AccountType)
        case transferFrom(AccountType)
        case other(String = "")

        var title: String {
            switch self {
            case .income: return "Поступление"
            case .salary: return "Заработная плата"
            case .agentFee: return "Агентские"
            case .equipment: return "Оборудование"
            case .consumables: return "Расходники"
            case .building: return "Помещение"
            case .laboratory: return "Лаборатория"
            case .taxes: return "Налоги"
            case .advertising: return "Реклама"
            case .loan: return "Кредит"
            case .banking: return "Банковские услуги"
            case .transferTo(let account): return "Перевод на счет \(account.title.uppercased())"
            case .transferFrom(let account): return "Перевод со счета \(account.title.uppercased())"
            case .other: return "Прочее"
            }
        }
    }
}
