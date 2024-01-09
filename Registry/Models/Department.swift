//
//  Department.swift
//  Registry
//
//  Created by Николай Фаустов on 22.12.2023.
//

import Foundation

public enum Department: String, Codable, Hashable, CaseIterable, Identifiable {
    case gynecology = "Гинекология"
    case obstetrics = "Акушерство"
    case therapy = "Терапия"
    case urology = "Урология"
    case ultrasound = "Ультразвуковая диагностика"
    case gastroenterology = "Гастроэнтерология"
    case endocrinology = "Эндокринология"
    case cardiology = "Кардиология"
    case vascularSurgery = "Сердечно-сосудистая хирургия"
    case functionalDiagnostics = "Функциональная диагностика"
    case neurology = "Неврология"
    case laboratory = "Лабораторные исследования"
    case procedure = "Процедурный кабинет"

    public var specialization: String {
        switch self {
        case .gynecology: return "Гинеколог"
        case .obstetrics: return "Акушер-гинеколог"
        case .therapy: return "Терапевт"
        case .urology: return "Уролог"
        case .ultrasound: return "Врач УЗИ"
        case .gastroenterology: return "Гастроэнтеролог"
        case .endocrinology: return "Эндокринолог"
        case .cardiology: return "Кардиолог"
        case .vascularSurgery: return "Сосудистый хирург"
        case .functionalDiagnostics: return "Врач функциональной диагностики"
        case .neurology: return "Невролог"
        case .laboratory: return "Врач лаборант"
        case .procedure: return "Медицинская сестра"
        }
    }

    public var id: Self {
        self
    }
}
