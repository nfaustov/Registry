//
//  DateText.swift
//  Registry
//
//  Created by Николай Фаустов on 09.01.2024.
//

import SwiftUI

struct DateText: View {
    // MARK: - Dependencies

    private let date: Date
    private let format: DateFormat

    // MARK: -

    init(_ date: Date, format: DateFormat) {
        self.date = date
        self.format = format
    }

    var body: some View {
        Text(format.string(from: date))
    }
}

#Preview {
    DateText(.now, format: .weekDay)
}

// MARK: - DateFormat

enum DateFormat: String {
    case time = "H:mm"
    case date = "dd.MM.YYYY"
    case dateTime = "dd.MM.YYYY H:mm"
    case weekDay = "d MMMM EEE"
    case timeWeekDay = "H:mm d MMMM EEE"
    case dayMonth = "d.MM"
    case monthYear = "LLLL YYYY"
    case birthDate = "d MMMM yyyy"
    case datePickerDate = "LLLL d EEEE"

    func string(from date: Date) -> String {
        DateFormatter.shared.dateFormat = rawValue
        return DateFormatter.shared.string(from: date).capitalized
    }
}
