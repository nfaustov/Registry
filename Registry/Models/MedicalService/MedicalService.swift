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
    let pricelistItem: PricelistItem.Snapshot
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

    func charge(_ action: ChargeAction, for role: KeyPath<MedicalService, Doctor?>) {
        switch role {
        case \.performer: salary(action)
        case \.agent: agentFee(action)
        default: ()
        }
    }

    var agentFee: Double {
        pricelistItem.fixedAgentFee ?? pricelistItem.price * 0.1
    }

    func pieceRateSalary(_ rate: Double) -> Double {
        pricelistItem.fixedSalary ?? pricelistItem.price * rate
    }

    private func salary(_ action: ChargeAction) {
        if let performer,
           let rate = performer.doctorSalary.rate,
           pricelistItem.category != .laboratory {
            let salary = pieceRateSalary(rate)
            performer.updateBalance(increment: action == .make ? salary : -salary)
        }
    }

    private func agentFee(_ action: ChargeAction) {
        if let agent {
            agent.updateBalance(increment: action == .make ? agentFee : -agentFee)
        }
    }
}

enum ChargeAction {
    case make, cancel
}
