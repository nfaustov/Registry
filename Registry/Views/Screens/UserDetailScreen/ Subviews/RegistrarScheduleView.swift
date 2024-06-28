//
//  RegistrarScheduleView.swift
//  Registry
//
//  Created by Николай Фаустов on 27.06.2024.
//

import SwiftUI

struct RegistrarScheduleView: View {

    var body: some View {
        Form {
            Section {
                Text("График работы")
            }
        }
    }
}

#Preview {
    RegistrarScheduleView()
}

// MARK: - Calculations

private extension RegistrarScheduleView {
    var monthDays: [WeekDay] {
        let calendar = Calendar(identifier: .iso8601)

        var month = [WeekDay]()

        guard let firstMonthDay = calendar.dateInterval(of: .month, for: .now)?.start else { return [] }

        for index in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: index, to: firstMonthDay) {
                month.append(WeekDay(date: day))
            }
        }

        return month
    }
}

private extension RegistrarScheduleView {
    struct WeekDay: Identifiable {
        var id: UUID = UUID()
        var date: Date

        var label: String {
            DateFormatter.shared.dateFormat = "EE, dd"
            return DateFormatter.shared.string(from: date)
        }

        var isToday: Bool {
            Calendar.current.isDate(date, inSameDayAs: .now)
        }

        func isSameDayAs(_ date: Date) -> Bool {
            Calendar.current.isDate(self.date, inSameDayAs: date)
        }
    }
}
