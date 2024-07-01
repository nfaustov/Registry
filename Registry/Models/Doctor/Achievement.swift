//
//  Achievement.swift
//  Registry
//
//  Created by Николай Фаустов on 01.07.2024.
//

import Foundation

extension Doctor {
    struct Achievement: Codable, Hashable, Identifiable {
        enum Kind: String, Codable, Hashable {
            case registrarOFMonth = "РЕГИСТРАТОР МЕСЯЦА"
        }

        let id: UUID
        let type: Achievement.Kind
        let icon: String
        let period: String
        let issueDate: Date

        init(id: UUID = UUID(), type: Achievement.Kind, icon: String, period: String) {
            self.id = id
            self.type = type
            self.icon = icon
            self.period = period
            issueDate = .now
        }
    }
}
