//
//  Sheet.swift
//  Registry
//
//  Created by Николай Фаустов on 22.12.2023.
//

import SwiftUI

enum Sheet: Identifiable {
    case report(Report)
    case createSpending(in: Report)
    case doctorSelection(date: Date)
    case doctorPayout(for: Doctor, disabled: Bool)
    case doctorFutureSchedules(doctorSchedule: DoctorSchedule)
    case addPatient(for: PatientAppointment)
    case addProcedurePatient(for: DoctorSchedule)
    case completedAppointment(appointment: PatientAppointment)
    case createBillTemplate(services: [MedicalService])
    case createDoctor
    case createPricelistItem
    case updateBalance(for: Binding<Person>, kind: UpdateBalanceKind)
    case billPayment(appointment: PatientAppointment, isPaid: Binding<Bool>)

    var id: UUID {
        UUID()
    }
}
