//
//  StatisticsPeriod.swift
//  Registry
//
//  Created by Николай Фаустов on 18.03.2024.
//

import Foundation

enum StatisticsPeriod: String, CaseIterable, Identifiable {
    case day = "День"
    case week = "Неделя"
    case month = "Месяц"
    case year = "Год"

    func start(for date: Date? = nil) -> Date {
        dateInterval(for: date ?? .now).start
    }

    func end(for date: Date? = nil) -> Date {
        dateInterval(for: date ?? .now).end
    }

    private func dateInterval(for date: Date) -> DateInterval {
        var interval: DateInterval? = DateInterval(start: .distantPast, end: .distantFuture)

        switch self {
        case .day:
            interval = Calendar.current.dateInterval(of: .day, for: date)
        case .week:
            interval = Calendar.current.dateInterval(of: .weekOfYear, for: date)
        case .month:
            interval = Calendar.current.dateInterval(of: .month, for: date)
        case .year:
            interval = Calendar.current.dateInterval(of: .year, for: date)
        }

        let endOfToday = Calendar.current.startOfDay(for: .now.addingTimeInterval(86_400))

        guard let interval else { fatalError() }

        if interval.end > endOfToday {
            return DateInterval(start: interval.start, end: endOfToday.addingTimeInterval(-1))
        } else {
            return DateInterval(start: interval.start, end: interval.end.addingTimeInterval(-1))
        }
    }

    var id: Self {
        self
    }
}
