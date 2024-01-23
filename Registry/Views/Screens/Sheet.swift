//
//  Sheet.swift
//  Registry
//
//  Created by Николай Фаустов on 22.12.2023.
//

import SwiftUI

enum Sheet: Identifiable {
    case report
    case createSpending
    case doctorSelection
    case doctorPayout(doctor: Doctor)
    case doctorFutureSchedules//(doctorSchedule: DoctorSchedule)
    case addPatient//(appointment: PatientAppointment)
    case completedAppointment//(appointment: PatientAppointment)
    case createBillTemplate//(services: [RenderedService])
    case createDoctor
    case createPricelistItem
    case billPayment//(appointment: PatientAppointment, includedPatientBalance: Double, bill: Bill, isPaid: Binding<Bool>)

    var id: UUID {
        UUID()
    }
}
