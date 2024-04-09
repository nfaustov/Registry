//
//  Payment.Purpose.swift
//  Registry
//
//  Created by Николай Фаустов on 21.02.2024.
//

import Foundation

public extension Payment {
    enum Purpose: Codable, Hashable {
        case collection
        case salary(String = "")
        case agentFee(String = "")
        case medicalServices(String = "")
        case refund(String = "")
        case toBalance(String = "")
        case fromBalance(String = "")
        case equipment(String = "")
        case consumables(String = "")
        case building(String = "")

        public var title: String {
            switch self {
            case .collection: return "Инкассация"
            case .salary: return "Заработная плата"
            case .agentFee: return "Агентские"
            case .medicalServices: return "Оплата услуг"
            case .refund: return "Возврат"
            case .toBalance: return "Пополнение баланса"
            case .fromBalance: return "Списание с баланса"
            case .equipment: return "Оборудование"
            case .consumables: return "Расходники"
            case .building: return "Помещение"
            }
        }

        public var descripiton: String {
            get {
                switch self {
                case .collection: return ""
                case .salary(let description): return description
                case .agentFee(let description): return description
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

        public static var userSelectableCases: [Payment.Purpose] {
            [.collection, .equipment(), .consumables(), .building()]
        }
    }
}
