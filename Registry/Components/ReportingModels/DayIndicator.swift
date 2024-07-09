//
//  DayIndicator.swift
//  Registry
//
//  Created by Николай Фаустов on 07.07.2024.
//

import Foundation

struct DayIndicator: Hashable, Identifiable {
    let id: UUID = UUID()
    let day: Date
    let indicator: Int
}
