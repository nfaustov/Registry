//
//  TreatmentPlan.swift
//  Registry
//
//  Created by Николай Фаустов on 20.02.2024.
//

import Foundation

struct TreatmentPlan: Codable, Hashable {
    let kind: Kind
    let startingDate: Date
    let expirationDate: Date

    init(kind: Kind, startingDate: Date = .now) {
        self.kind = kind
        self.startingDate = startingDate
        self.expirationDate = Calendar.current.date(byAdding: .year, value: 1, to: startingDate)!
    }
}

extension TreatmentPlan {
    enum Kind: String, Codable {
        case basic = "Базовый"
        case pregnancy = "Беременность" 
    }
}
