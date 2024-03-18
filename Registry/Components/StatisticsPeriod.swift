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

    public var start: Date {
        switch self {
        case .day:
            return Calendar.current.startOfDay(for: .now)
        case .month:
            let dateComponents = Calendar.current.dateComponents([.year, .month], from: .now)
            return Calendar.current.date(from: dateComponents)!
        }
    }

    public var end: Date {
        Calendar.current.startOfDay(for: .now.addingTimeInterval(86_400))
    }

    public var id: Self {
        self
    }
}
