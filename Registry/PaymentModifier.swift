//
//  PaymentModifier.swift
//  Registry
//
//  Created by Николай Фаустов on 05.05.2024.
//

import Foundation
import SwiftData

@ModelActor
actor PaymentModifier {
    func execute() {
        let paymentsDescriptor = FetchDescriptor<Payment>()
        let doctorsDescriptor = FetchDescriptor<Doctor>()

        guard let payments = try? modelContext.fetch(paymentsDescriptor),
              let doctors = try? modelContext.fetch(doctorsDescriptor) else { return }

        let payoutPayments = payments.filter { $0.purpose.title == "Заработная плата" || $0.purpose.title == "Агентские" }
        for payment in payoutPayments {
            guard let doctor = doctors.first(where: { $0.initials == payment.purpose.descripiton }) else { return }
            // TODO: change purpose property to let constant
            payment.purpose = .doctorPayout("Врач: \(payment.purpose.descripiton)")
            doctor.transactions?.append(payment)
        }
    }
}
