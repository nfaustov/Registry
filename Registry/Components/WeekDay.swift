//
//  WeekDay.swift
//  Registry
//
//  Created by Николай Фаустов on 02.07.2024.
//

import Foundation

struct WeekDay: Identifiable {
    let id: UUID = UUID()
    var date: Date

    var label: String {
        DateFormatter.shared.dateFormat = "EE, dd"
        return DateFormatter.shared.string(from: date)
    }

    var dayLabel: String {
        DateFormatter.shared.dateFormat = "d"
        return DateFormatter.shared.string(from: date)
    }

    var isToday: Bool {
        Calendar.current.isDate(date, inSameDayAs: .now)
    }

    func isSameDayAs(_ date: Date) -> Bool {
        Calendar.current.isDate(self.date, inSameDayAs: date)
    }
}
