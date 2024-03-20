//
//  TreatmentPlan.swift
//  Registry
//
//  Created by Николай Фаустов on 20.02.2024.
//

import Foundation

public struct TreatmentPlan: Codable, Hashable {
    public let kind: Kind
    public let startingDate: Date
    public let expirationDate: Date

    public init(kind: Kind, startingDate: Date = .now) {
        self.kind = kind
        self.startingDate = startingDate
        self.expirationDate = Calendar.current.date(byAdding: .year, value: 1, to: startingDate)!
    }
}

public extension TreatmentPlan {
    enum Kind: String, Codable {
        case basic = "Базовый"
        case pregnancy = "Беременность" 
    }
}
