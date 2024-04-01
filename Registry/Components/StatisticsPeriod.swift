//
//  StatisticsPeriod.swift
//  Registry
//
//  Created by Николай Фаустов on 18.03.2024.
//

import Foundation

public enum StatisticsPeriod: String, CaseIterable, Identifiable {
    case day = "День"
    case month = "Месяц"

    public func start(for date: Date? = nil) -> Date {
        switch self {
        case .day:
            return Calendar.current.startOfDay(for: date ?? .now)
        case .month:
            let dateComponents = Calendar.current.dateComponents([.year, .month], from: date ?? .now)
            return Calendar.current.date(from: dateComponents)!
        }
    }

    public func end(for date: Date? = nil) -> Date {
        Calendar.current.startOfDay(for: (date ?? .now).addingTimeInterval(86_400))
    }

    public var id: Self {
        self
    }
}
