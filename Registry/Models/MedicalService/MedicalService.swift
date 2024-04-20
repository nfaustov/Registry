//
//  MedicalService.swift
//  Registry
//
//  Created by Николай Фаустов on 18.04.2024.
//

import Foundation
import SwiftData

extension RegistrySchemaV2 {
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
                    performer.charge(as: \.performer, amount: action == .charge ? fixedSalary: -fixedSalary)
                } else {
                    let salary = pricelistItem.price * rate
                    performer.charge(as: \.performer, amount: action == .charge ? salary : -salary)
                }
            }
        }

        private func agentFee(_ action: ChargeAction) {
            if let agent {
                if let fixedAgentFee = pricelistItem.fixedAgentFee {
                    agent.charge(as: \.agent, amount: action == .charge ? fixedAgentFee : -fixedAgentFee)
                } else {
                    let agentFee = pricelistItem.price * 0.1
                    agent.charge(as: \.agent, amount: action == .charge ? agentFee : -agentFee)
                }
            }
        }
    }
}

extension RegistrySchemaV3 {
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
                    performer.charge(as: \.performer, amount: action == .charge ? fixedSalary: -fixedSalary)
                } else {
                    let salary = pricelistItem.price * rate
                    performer.charge(as: \.performer, amount: action == .charge ? salary : -salary)
                }
            }
        }

        private func agentFee(_ action: ChargeAction) {
            if let agent {
                if let fixedAgentFee = pricelistItem.fixedAgentFee {
                    agent.charge(as: \.agent, amount: action == .charge ? fixedAgentFee : -fixedAgentFee)
                } else {
                    let agentFee = pricelistItem.price * 0.1
                    agent.charge(as: \.agent, amount: action == .charge ? agentFee : -agentFee)
                }
            }
        }
    }
}

enum ChargeAction {
    case charge, cancel
}
