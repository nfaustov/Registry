//
//  Salary.swift
//  Registry
//
//  Created by Николай Фаустов on 22.12.2023.
//

import Foundation

public enum Salary: Codable, Hashable, CaseIterable {
    case pieceRate(rate: Double = 0.4)
    case monthly(amount: Int = 0)
    case hourly(amount: Int = 0)

    public var title: String {
        switch self {
        case .pieceRate: return "Сдельная"
        case .monthly: return "Ежемесячная"
        case .hourly: return "Почасовая"
        }
    }

    public var rate: Double? {
        switch self {
        case .pieceRate(let rate):
            return rate
        default: return nil
        }
    }

    public static var allCases: [Salary] {
        [.pieceRate(), .monthly(), .hourly()]
    }
}
