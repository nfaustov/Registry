//
//  Salary.swift
//  Registry
//
//  Created by Николай Фаустов on 22.12.2023.
//

import Foundation

extension RegistrySchemaV1 {
    enum Salary: Codable, Hashable, CaseIterable {
        case pieceRate(rate: Double = 0.4)
        case monthly(amount: Int = 0)
        case hourly(amount: Int = 0)

        var title: String {
            switch self {
            case .pieceRate: return "Сдельная"
            case .monthly: return "Ежемесячная"
            case .hourly: return "Почасовая"
            }
        }

        var rate: Double? {
            switch self {
            case .pieceRate(let rate):
                return rate
            default: return nil
            }
        }

        static var allCases: [Salary] {
            [.pieceRate(), .monthly(), .hourly()]
        }
    }
}

extension RegistrySchemaV3 {
    enum Salary: Codable, Hashable, CaseIterable {
        case pieceRate(rate: Double = 0.4, minAmount: Double? = nil)
        case monthly(amount: Int = 0)
        case hourly(amount: Int = 0)

        var title: String {
            switch self {
            case .pieceRate: return "Сдельная"
            case .monthly: return "Ежемесячная"
            case .hourly: return "Почасовая"
            }
        }

        var rate: Double? {
            switch self {
            case .pieceRate(let rate, _):
                return rate
            default: return nil
            }
        }

        var monthlyAmount: Int? {
            switch self {
            case .monthly(let amount):
                return amount
            default: return nil
            }
        }

        var minAmount: Double? {
            switch self {
            case .pieceRate(_, let minAmount):
                return minAmount
            default: return nil
            }
        }

        static var allCases: [Salary] {
            [.pieceRate(), .monthly(), .hourly()]
        }
    }
}

