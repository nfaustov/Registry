//
//  SuperUser.swift
//  Registry
//
//  Created by Николай Фаустов on 14.03.2024.
//

import Foundation

final class SuperUser: User {
    let id: UUID
    var secondName: String
    var firstName: String
    var patronymicName: String
    var phoneNumber: String
    var balance: Double
    var accessLevel: UserAccessLevel
    var image: Data?

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
        image = nil
    }

    static var boss: SuperUser = SuperUser(
        secondName: "Фаустов",
        firstName: "Николай",
        patronymicName: "Игоревич",
        phoneNumber: "+7 (920) 500-11-00"
    )
}
