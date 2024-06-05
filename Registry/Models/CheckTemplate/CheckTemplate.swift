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
        services: [MedicalService]? = [],
        discount: Double = .zero
    ) {
        self.title = title
        self.services = services
        self.discount = discount
    }

    func getCopy() -> [MedicalService] {
        var servicesCopy: [MedicalService] = []

        guard let services else { return [] }

        for service in services {
            let medicalService = MedicalService(pricelistItem: service.pricelistItem, performer: service.performer, agent: service.agent)
            servicesCopy.append(medicalService)
        }

        return servicesCopy
    }
}
