//
//  MedicalService.swift
//  Registry
//
//  Created by Николай Фаустов on 18.04.2024.
//

import Foundation
import SwiftData

@Model
final class MedicalService {
    let pricelistItem: PricelistItem.Snapshot = PricelistItem.Snapshot(id: "", category: .gynecology, title: "", price: 0)
    @Relationship(inverse: \Doctor.performedServices)
    var performer: Doctor?
    @Relationship(inverse: \Doctor.appointedServices)
    var agent: Doctor?
    @Attribute(.externalStorage)
    private(set) var conclusion: Data?

    var check: Check?
    var refund: Refund?
    var checkTemplates: [CheckTemplate]?

    var date: Date? {
        check?.payment?.date
    }

    init(
        pricelistItem: PricelistItem.Snapshot,
        performer: Doctor? = nil,
        agent: Doctor? = nil,
        conclusion: Data? = nil
    ) {
        self.pricelistItem = pricelistItem
        self.performer = performer
        self.agent = agent
        self.conclusion = conclusion
    }

    func makeCharges() {
        salary(.charge)
        agentFee(.charge)
    }

    func cancelCharges() {
        salary(.cancel)
        agentFee(.cancel)
    }

    private func salary(_ action: ChargeAction) {
        if let performer,
           let rate = performer.doctorSalary.rate,
           pricelistItem.category != .laboratory {
            if let fixedSalary = pricelistItem.fixedSalary {
                performer.updateBalance(increment: action == .charge ? fixedSalary : -fixedSalary)
            } else {
                let salary = pricelistItem.price * rate
                performer.updateBalance(increment: action == .charge ? salary : -salary)
            }
        }
    }

    private func agentFee(_ action: ChargeAction) {
        if let agent {
            if let fixedAgentFee = pricelistItem.fixedAgentFee {
                agent.updateBalance(increment: action == .charge ? fixedAgentFee : -fixedAgentFee)
            } else {
                let agentFee = pricelistItem.price * 0.1
                agent.updateBalance(increment: action == .charge ? agentFee : -agentFee)
            }
        }
    }
}

enum ChargeAction {
    case charge, cancel
}
