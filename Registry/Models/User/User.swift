//
//  User.swift
//  Registry
//
//  Created by Николай Фаустов on 12.03.2024.
//

import Foundation

public protocol User: Person {
    var accessLevel: UserAccessLevel { get set }
}

public enum UserAccessLevel: Int, Codable, Hashable, Identifiable {
    case anonymous = 0
    case doctor = 1
    case registrar = 2
    case boss = 3

    public var title: String {
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

    public var id: Self {
        self
    }

    public static var selectableCases: [UserAccessLevel] {
        [.doctor, .registrar]
    }
}

public struct AnyUser: User, Codable, Hashable {
    public let id: UUID
    public var secondName: String
    public var firstName: String
    public var patronymicName: String
    public var phoneNumber: String
    public private(set) var balance: Double
    public var accessLevel: UserAccessLevel
    public var image: Data?
}

public extension User {
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
    public static func < (lhs: UserAccessLevel, rhs: UserAccessLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
