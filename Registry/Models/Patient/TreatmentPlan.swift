//
//  TreatmentPlan.swift
//  Registry
//
//  Created by Николай Фаустов on 20.02.2024.
//

import Foundation
import SwiftData

@Model
final class TreatmentPlan {
    let kind: Kind
    let startingDate: Date
    let expirationDate: Date

    var patient: Patient?

    init(kind: Kind, startingDate: Date = .now) {
        self.kind = kind
        self.startingDate = startingDate

        let yearLaterDate = Calendar.current.date(byAdding: .year, value: 1, to: startingDate)!
        let endOfyearLaterDate = Calendar.current.startOfDay(for: yearLaterDate.addingTimeInterval(86_400)).addingTimeInterval(-1)
        self.expirationDate = endOfyearLaterDate
    }
}

extension TreatmentPlan {
    enum Kind: String, Codable, Identifiable, CaseIterable {
        case basic = "Базовый"
        case pregnancy = "Беременность"

        var id: String {
            switch self {
            case .basic:
                "ТРИТ-БАЗ"
            case .pregnancy:
                "ТРИТ-БЕРЕМ"
            }
        }
    }
}
