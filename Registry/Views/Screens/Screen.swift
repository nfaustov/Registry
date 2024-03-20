//
//  Screen.swift
//  Registry
//
//  Created by Николай Фаустов on 22.12.2023.
//

import Foundation
import SwiftUI

enum Screen: CaseIterable, Hashable, Identifiable {
    case schedule
    case cashbox
    case specialists
    case patients
    case medicalServices
    case indicators

    var title: String {
        switch self {
        case .schedule:
            return "Расписание"
        case .cashbox:
            return "Касса"
        case .specialists:
            return "Специалисты"
        case .patients:
            return "Пациенты"
        case .medicalServices:
            return "Услуги"
        case .indicators:
            return "Статистика"
        }
    }

    var imageName: String {
        switch self {
        case .schedule:
            return "calendar"
        case .cashbox:
            return "rublesign.square"
        case .specialists:
            return "person.2"
        case .patients:
            return "person.crop.square.filled.and.at.rectangle"
        case .medicalServices:
            return "list.bullet.clipboard"
        case .indicators:
            return "chart.line.uptrend.xyaxis"
        }
    }

    var color: Color {
        switch self {
        case .schedule:
            return .orange
        case .cashbox:
            return .purple
        case .specialists:
            return .green
        case .patients:
            return .indigo
        case .medicalServices:
            return .teal
        case .indicators:
            return .pink
        }
    }

    var id: Self {
        self
    }

    static var registrarCases: [Screen] {
        return [.schedule, .cashbox, .specialists, .patients, .medicalServices]
    }
}
