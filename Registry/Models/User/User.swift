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

public enum UserAccessLevel: Int, Codable, Hashable, CaseIterable, Identifiable {
    case anonymous = 0
    case doctor = 1
    case registrar = 2
    case boss = 3

    public var id: Self {
        self
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
            accessLevel: accessLevel
        )
    }
}

extension UserAccessLevel: Comparable {
    public static func < (lhs: UserAccessLevel, rhs: UserAccessLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
