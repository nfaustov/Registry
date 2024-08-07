//
//  DoctorMoneyTransaction.swift
//  Registry
//
//  Created by Николай Фаустов on 07.05.2024.
//

import Foundation

struct DoctorMoneyTransaction: MoneyTransaction, Hashable, Identifiable {
    let id: UUID
    let date: Date
    let description: String
    let patient: String?
    let value: Double
    let kind: DoctorMoneyTransaction.Kind
    let refunded: Bool

    init(medicalService: MedicalService) {
        id = UUID()
        self.date = medicalService.date ?? .now
        self.description = medicalService.title
        value = medicalService.agentFee
        kind = .agentFee
        refunded = medicalService.refund != nil

        if let patient = medicalService.check?.appointments?.first?.patient {
            self.patient = patient.initials
        } else { patient = nil }
    }

    init(medicalService: MedicalService, doctorSalaryRate: Double) {
        id = UUID()
        self.date = medicalService.date ?? .now
        self.description = medicalService.title
        value = medicalService.pieceRateSalary(doctorSalaryRate)
        kind = .performerFee
        refunded = medicalService.refund != nil

        if let patient = medicalService.check?.appointments?.first?.patient {
            self.patient = patient.initials
        } else { patient = nil }
    }

    init(payment: Payment) {
        id = UUID()
        self.date = payment.date
        self.description = payment.details
        self.patient = nil
        self.value = payment.methods.reduce(0.0) { $0 + $1.value }

        if value > 0 {
            kind = .refill
        } else {
            kind = .payout
        }

        refunded = false
    }
}

// MARK: - Kind

extension DoctorMoneyTransaction {
    enum Kind: MoneyTransactionKind {
        case agentFee
        case performerFee
        case payout
        case refill

        var title: String {
            switch self {
            case .agentFee:
                "Агентские"
            case .performerFee:
                "Заработная плата"
            case .payout:
                "Выплата"
            case .refill:
                "Пополнение"
            }
        }
    }
}
