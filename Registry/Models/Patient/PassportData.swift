//
//  PassportData.swift
//  Registry
//
//  Created by Николай Фаустов on 20.02.2024.
//

import Foundation

public extension Patient {
    struct PassportData: Codable, Hashable {
        public var gender: Gender
        public var seriesNumber: String
        public var birthday: Date
        public var issueDate: Date
        public var authority: String

        public init(
            gender: Gender,
            seriesNumber: String,
            birthday: Date,
            issueDate: Date,
            authority: String
        ) {
            self.gender = gender
            self.seriesNumber = seriesNumber
            self.birthday = birthday
            self.issueDate = issueDate
            self.authority = authority
        }
    }
}

public enum Gender: String, Codable, Hashable, CaseIterable {
    case male = "муж"
    case female = "жен"
    case unknown = "неизвестен"
}
