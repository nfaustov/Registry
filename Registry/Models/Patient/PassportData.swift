//
//  PassportData.swift
//  Registry
//
//  Created by Николай Фаустов on 20.02.2024.
//

import Foundation

extension Patient {
    struct PassportData: Codable, Hashable {
        var gender: Gender
        var seriesNumber: String
        var birthday: Date
        var issueDate: Date
        var authority: String

        init(
            gender: Gender = .unknown,
            seriesNumber: String = "",
            birthday: Date = Date(timeIntervalSinceReferenceDate: 0),
            issueDate: Date = Date(timeIntervalSinceReferenceDate: 0),
            authority: String = ""
        ) {
            self.gender = gender
            self.seriesNumber = seriesNumber
            self.birthday = birthday
            self.issueDate = issueDate
            self.authority = authority
        }
    }
}

enum Gender: String, Codable, Hashable, CaseIterable {
    case male = "муж"
    case female = "жен"
    case unknown = "неизвестен"
}
