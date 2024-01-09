//
//  DateFormatter+Shared.swift
//  Registry
//
//  Created by Николай Фаустов on 06.01.2024.
//

import Foundation

extension DateFormatter {
    static let shared: DateFormatter = {
       let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
}
