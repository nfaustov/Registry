//
//  CheckTemplate.swift
//  Registry
//
//  Created by Николай Фаустов on 18.04.2024.
//

import Foundation
import SwiftData

@Model
final class CheckTemplate {
    var title: String = ""
    @Relationship(inverse: \MedicalService.checkTemplates)
    var services: [MedicalService]?
    var discount: Double = Double.zero

    init(
        title: String,
        services: [MedicalService]? = nil,
        discount: Double = .zero
    ) {
        self.title = title
        self.services = services
        self.discount = discount
    }
}
