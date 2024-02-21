//
//  Patient.swift
//  Registry
//
//  Created by Николай Фаустов on 20.02.2024.
//

import Foundation
import SwiftData

@Model
public final class Patient: Person {
    public var id: UUID = UUID()
    public var secondName: String = ""
    public var firstName: String =  ""
    public var patronymicName: String = ""
    public var phoneNumber: String = ""
    public var balance: Double = Double.zero
    public var passport: PassportData?
    public var placeOfResidence: PlaceOfResidence?
    public var treatmentPlan: TreatmentPlan?
    public var createdAt: Date = Date.now
    public var visits: [Visit]

    public init(
        id: UUID = UUID(),
        secondName: String,
        firstName: String,
        patronymicName: String,
        phoneNumber: String,
        balance: Double = 0,
        passport: PassportData? = nil,
        placeOfResidence: PlaceOfResidence? = nil,
        treatmentPlan: TreatmentPlan? = nil,
        visits: [Visit] = []
    ) {
        self.id = id
        self.secondName = secondName
        self.firstName = firstName
        self.patronymicName = patronymicName
        self.phoneNumber = phoneNumber
        self.balance = balance
        self.passport = passport
        self.placeOfResidence = placeOfResidence
        self.treatmentPlan = treatmentPlan
        self.createdAt = .now
        self.visits = visits
    }
}
