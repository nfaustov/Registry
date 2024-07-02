//
//  Achievement.swift
//  Registry
//
//  Created by Николай Фаустов on 01.07.2024.
//

import Foundation

extension Doctor {
    struct Achievement: Codable, Hashable, Identifiable {
        let id: UUID
        let kind: Achievement.Kind
        let period: String
        let issueDate: Date

        init(id: UUID = UUID(), kind: Achievement.Kind, period: String) {
            self.id = id
            self.kind = kind
            self.period = period
            issueDate = .now
        }
    }
}

extension Doctor.Achievement {
    enum Kind: String, Codable, Hashable {
        case registrarOFMonth = "РЕГИСТРАТОР МЕСЯЦА"

        var icon: String {
            switch self {
            case .registrarOFMonth:
                "star.square"
            }
        }
    }
}
