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
    }
}

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
}
