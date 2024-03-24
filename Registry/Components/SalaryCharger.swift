//
//  SalaryCharger.swift
//  Registry
//
//  Created by Николай Фаустов on 23.03.2024.
//

import Foundation

public struct SalaryCharger {
    static func charge(for subject: Payment.Subject, doctors: [Doctor]) {
        for service in subject.services {
            if let performer = service.performer, let rate = performer.salary.rate {
                var salary = Double.zero

                if let fixedSalaryAmount = service.pricelistItem.salaryAmount {
                    salary = fixedSalaryAmount
                } else {
                    salary = service.pricelistItem.price * rate
                }

                guard let doctor = doctors.first(where: { $0.id == performer.id }) else { return }

                doctor.charge(as: \.performer, amount: subject.isRefund ? -salary : salary)
            }

            if let agent = service.agent {
                let agentFee = service.pricelistItem.price * 0.1

                guard let doctor = doctors.first(where: { $0.id == agent.id }) else { return }

                doctor.charge(as: \.agent, amount: subject.isRefund ? -agentFee : agentFee)
            }
        }
    }
}
