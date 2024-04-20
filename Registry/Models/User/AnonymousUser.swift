//
//  AnonymousUser.swift
//  Registry
//
//  Created by Николай Фаустов on 28.03.2024.
//

import Foundation

final class AnonymousUser: User {
    let id: UUID
    var secondName: String
    var firstName: String
    var patronymicName: String
    var phoneNumber: String
    var balance: Double
    var accessLevel: UserAccessLevel
    var image: Data?

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
