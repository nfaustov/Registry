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
    private(set) var expirationDate: Date

    var patient: Patient?

    init(kind: Kind, startingDate: Date = .now) {
        self.kind = kind
        self.startingDate = startingDate

        let yearLaterDate = Calendar.current.date(byAdding: .year, value: 1, to: startingDate)!
        let endOfyearLaterDate = Calendar.current.startOfDay(for: yearLaterDate.addingTimeInterval(86_400)).addingTimeInterval(-1)
        self.expirationDate = endOfyearLaterDate
    }

    func complete() {
        if kind.isPregnancyAI {
            expirationDate = .now
        }
    }
}

extension TreatmentPlan {
    enum Kind: String, Codable, Identifiable, CaseIterable {
        case basic = "Базовый"
        case pregnancy = "Беременность"
        case pregnancyAI = "Ведение беременности"
        case pregnancyAIFirstHalf = "Ведение беременности (I-II триместр)"
        case pregnancyAISecondHalf = "Ведение беременности (II-III триместр)"
        case pregnancyTwinsAI = "Ведение беременности (двойня)"
        case pregnancyTwinsAIFirstHalf = "Ведение беременности (I-II триместр)(двойня)"
        case pregnancyTwinsAISecondHalf = "Ведение беременности (II-III триместр)(двойня)"

        var id: String {
            switch self {
            case .basic:
                "ТРИТ-БАЗ"
            case .pregnancy:
                "ТРИТ-БЕРЕМ"
            case .pregnancyAI:
                "В01.001.005.001"
            case .pregnancyAIFirstHalf:
                "В01.001.005.002"
            case .pregnancyAISecondHalf:
                "В01.001.005.003"
            case .pregnancyTwinsAI:
                "В01.001.005.004"
            case .pregnancyTwinsAIFirstHalf:
                "В01.001.005.005"
            case .pregnancyTwinsAISecondHalf:
                "В01.001.005.006"
            }
        }

        var isPregnancyAI: Bool {
            Self.pregnancyAICases.contains(self)
        }

        static var pregnancyAICases:  [TreatmentPlan.Kind] {
            [
                .pregnancyAI,
                .pregnancyAIFirstHalf,
                .pregnancyAISecondHalf,
                .pregnancyTwinsAI,
                .pregnancyTwinsAIFirstHalf,
                .pregnancyTwinsAISecondHalf
            ]
        }
    }
}
