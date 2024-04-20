//
//  User.swift
//  Registry
//
//  Created by Николай Фаустов on 12.03.2024.
//

import Foundation

protocol User: Person {
    var accessLevel: UserAccessLevel { get set }
}

enum UserAccessLevel: Int, Codable, Hashable, Identifiable {
    case anonymous = 0
    case doctor = 1
    case registrar = 2
    case boss = 3

    var title: String {
        switch self {
        case .anonymous:
            "Анонимный пользователь"
        case .doctor:
            "Врач"
        case .registrar:
            "Регистратор"
        case .boss:
            "Руководитель"
        }
    }

    var id: Self {
        self
    }

    static var selectableCases: [UserAccessLevel] {
        [.doctor, .registrar]
    }
}

struct AnyUser: User, Codable, Hashable {
    let id: UUID
    var secondName: String
    var firstName: String
    var patronymicName: String
    var phoneNumber: String
    var balance: Double
    var accessLevel: UserAccessLevel
    var image: Data?
}

extension User {
    var asAnyUser: AnyUser {
        AnyUser(
            id: id,
            secondName: secondName,
            firstName: firstName,
            patronymicName: patronymicName,
            phoneNumber: phoneNumber,
            balance: balance,
            accessLevel: accessLevel,
            image: image
        )
    }
}

extension UserAccessLevel: Comparable {
    static func < (lhs: UserAccessLevel, rhs: UserAccessLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
