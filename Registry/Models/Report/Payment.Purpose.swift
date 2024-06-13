//
//  Payment.Purpose.swift
//  Registry
//
//  Created by Николай Фаустов on 21.02.2024.
//

import Foundation

extension Payment {
    enum Purpose: Codable, Hashable {
        case collection
        case salary(String = "")
        case agentFee(String = "")
        case doctorPayout(String = "")
        case medicalServices(String = "")
        case refund(String = "")
        case toBalance(String = "")
        case fromBalance(String = "")
        case equipment(String = "")
        case consumables(String = "")
        case building(String = "")
        case laboratory(String = "")
        case taxes
        case advertising(String = "")
        case loan
        case banking
        case other(String = "")

        var title: String {
            switch self {
            case .collection: return "Инкассация"
            case .salary: return "Заработная плата"
            case .agentFee: return "Агентские"
            case .doctorPayout: return "Выплата"
            case .medicalServices: return "Оплата услуг"
            case .refund: return "Возврат"
            case .toBalance: return "Пополнение баланса"
            case .fromBalance: return "Списание с баланса"
            case .equipment: return "Оборудование"
            case .consumables: return "Расходники"
            case .building: return "Помещение"
            case .laboratory: return "Лаборатория"
            case .taxes: return "Налоги"
            case .advertising: return "Реклама"
            case .loan: return "Кредит"
            case .banking: return "Банковские услуги"
            case .other: return "Прочее"
            }
        }

        var descripiton: String {
            get {
                switch self {
                case .collection: return ""
                case .salary(let description): return description
                case .agentFee(let description): return description
                case .doctorPayout(let description): return description
                case .medicalServices(let description): return description
                case .refund(let description): return description
                case .toBalance(let description): return description
                case .fromBalance(let description): return description
                case .equipment(let description): return description
                case .consumables(let description): return description
                case .building(let description): return description
                case .laboratory(let description): return description
                case .taxes: return ""
                case .advertising(let description): return description
                case .loan: return ""
                case .banking: return ""
                case .other(let description): return description
                }
            }
            set {
                switch self {
                case .salary: self = .salary(newValue)
                case .agentFee: self = .agentFee(newValue)
                case .doctorPayout: self = .doctorPayout(newValue)
                case .medicalServices: self = .medicalServices(newValue)
                case .refund: self = .refund(newValue)
                case .toBalance: self = .toBalance(newValue)
                case .fromBalance: self = .fromBalance(newValue)
                case .equipment: self = .equipment(newValue)
                case .consumables: self = .consumables(newValue)
                case .building: self = .building(newValue)
                default: break
                }
            }
        }

        static var userSelectableCases: [Payment.Purpose] {
            [.collection, .equipment(), .consumables(), .building()]
        }
    }
}
