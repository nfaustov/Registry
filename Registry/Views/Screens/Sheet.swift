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
    case doctorPayout(for: Doctor, disabled: Bool, isSinglePatient: Bool)
    case doctorFutureSchedules(doctorSchedule: DoctorSchedule)
    case addPatient(for: PatientAppointment)
    case addProcedurePatient(for: DoctorSchedule)
    case completedAppointment(appointment: PatientAppointment)
    case createBillTemplate(services: [MedicalService])
    case createDoctor
    case createPricelistItem
    case updateBalance(for: AccountablePerson, kind: UpdateBalanceKind)
    case billPayment(patient: Patient, check: Check, isPaid: Binding<Bool>)
    case createNote(for: NoteKind)
    case accountDetail(account: CheckingAccount)
    case balanceDetail(persons: [AccountablePerson])
    case allTransactions
    case patientsReportingDetail

    var id: UUID {
        UUID()
    }
}
