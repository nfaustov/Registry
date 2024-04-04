//
//  AnonymousUser.swift
//  Registry
//
//  Created by Николай Фаустов on 28.03.2024.
//

import Foundation

public final class AnonymousUser: User {
    public let id: UUID
    public var secondName: String
    public var firstName: String
    public var patronymicName: String
    public var phoneNumber: String
    public var balance: Double
    public var accessLevel: UserAccessLevel
    public var image: Data?

    init() {
        id = UUID()
        secondName = ""
        firstName = ""
        patronymicName = ""
        phoneNumber = ""
        balance = 0
        accessLevel = .anonymous
        image = nil
    }
}
