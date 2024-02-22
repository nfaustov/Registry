//
//  WorkingHours.swift
//  Registry
//
//  Created by Николай Фаустов on 06.01.2024.
//

import Foundation

struct WorkingHours {
    var range: ClosedRange<Date>
    var start: Date
    var end: Date

    init(for date: Date) {
        let calendar = Calendar.current

        let dateComponents = calendar.dateComponents([.year, .month, .day, .weekday], from: date)
        var op = dateComponents
        var cl = dateComponents

        switch dateComponents.weekday {
        case 1:
            op.hour = 8
            cl.hour = 15
        case 7:
            op.hour = 8
            cl.hour = 18
        default:
            op.hour = 7
            op.minute = 30
            cl.hour = 19
            cl.minute = 30
        }

        start = calendar.date(from: op) ?? Date()
        end = calendar.date(from: cl) ?? Date()
        range = start...end
    }
}
