//
//  SuperUser.swift
//  Registry
//
//  Created by Николай Фаустов on 14.03.2024.
//

import Foundation

public final class SuperUser: User {
    public var id: UUID
    public var secondName: String
    public var firstName: String
    public var patronymicName: String
    public var phoneNumber: String
    public var balance: Double
    public var accessLevel: UserAccessLevel

    init(
        id: UUID = UUID(),
        secondName: String,
        firstName: String,
        patronymicName: String,
        phoneNumber: String
    ) {
        self.id = id
        self.secondName = secondName
        self.firstName = firstName
        self.patronymicName = patronymicName
        self.phoneNumber = phoneNumber
        balance = 0
        accessLevel = .boss
    }
}