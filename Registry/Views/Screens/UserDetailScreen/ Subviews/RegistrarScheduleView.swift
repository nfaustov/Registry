//
//  RegistrarScheduleView.swift
//  Registry
//
//  Created by Николай Фаустов on 27.06.2024.
//

import SwiftUI

struct RegistrarScheduleView: View {
    // MARK: - Dependencies

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
    func month(for date: Date) -> [WeekDay] {
        let calendar = Calendar(identifier: .iso8601)

        guard let interval = calendar.dateInterval(of: .month, for: .now),
              let days = calendar.dateComponents([.day], from: interval.start, to: interval.end).day else { return [] }

        return (0..<days).map {
            WeekDay(date: calendar.date(byAdding: .day, value: $0, to: interval.start)!)
        }
    }
}
