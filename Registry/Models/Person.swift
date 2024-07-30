//
//  Person.swift
//  Registry
//
//  Created by Николай Фаустов on 22.12.2023.
//

import Foundation

protocol Accountable: AnyObject {
    var balance: Double { get }
    var transactions: [Payment]? { get }

    func updateBalance(increment: Double, allRoles: Bool)
    func assignTransaction(_ transaction: Payment)
}

protocol Person {
    var id: UUID { get }
    var secondName: String { get set }
    var firstName: String { get set }
    var patronymicName: String { get set }
    var phoneNumber: String { get set }
    var image: Data? { get set }
}

extension Person {
    var fullName: String {
        secondName + " " + firstName + " " + patronymicName
    }

    var initials: String {
        guard let firstNameLetter = firstName.first,
              let patronymicNameLetter = patronymicName.first else { return secondName }

        return "\(secondName) \(firstNameLetter).\(patronymicNameLetter)."
    }
}

typealias AccountablePerson = Person & Accountable
