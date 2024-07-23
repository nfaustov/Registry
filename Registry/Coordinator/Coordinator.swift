//
//  Coordinator.swift
//  Registry
//
//  Created by Николай Фаустов on 22.12.2023.
//

import SwiftUI

final class Coordinator: ObservableObject {
    @Published private(set) var user: User?

    @Published var path = NavigationPath()
    @Published var sheet: Sheet? = nil {
        didSet {
            if sheet == nil {
                onSheetDisappear?()
                onSheetDisappear = nil
            }
        }
    }

    private var onSheetDisappear: (() -> Void)? = nil

    func push(_ route: Route) {
        path.append(route)
    }

    func present(_ sheet: Sheet, onDisappear: (() -> Void)? = nil) {
        self.sheet = sheet
        onSheetDisappear = onDisappear
    }

    func pop() {
        path.removeLast()
    }

    func clearPath() {
        path.removeLast(path.count)
    }

    func logIn(_ user: User) {
        self.user = user
    }

    func logOut() {
        user = nil
    }
}

// MARK: - ViewBuilders

extension Coordinator {
    @ViewBuilder func setRootView(_ screen: Screen) -> some View {
        switch screen {
        case .schedule:
            ScheduleScreen()
        case .cashbox:
            CashboxScreen()
        case .specialists:
            DoctorsScreen()
        case .patients:
            PatientsScreen()
        case .medicalServices:
            MedicalServicesScreen()
        case .dashboard:
            DashboardScreen()
        case .userDetail:
            UserDetailScreen()
        case .debug:
            DebugScreen()
        }
    }

    @ViewBuilder func destinationView(_ route: Route) -> some View {
        switch route {
        case .appointments:
            AppointmentsRegisterScreen()
        case .bill(let appointment, let purpose):
            BillScreen(appointment: appointment)
                .servicesTablePurpose(purpose)
        case .doctorDetail(let doctor):
            DoctorDetailScreen(doctor: doctor)
        case .patientCard(let patient):
            PatientCardScreen(patient: patient)
        case .contract(let patient, let check):
            ContractScreen(patient: patient, check: check)
        case .patientsReportingDetail:
            PatientsReportingDetail()
        }
    }

    @ViewBuilder func sheetContent(_ sheet: Sheet) -> some View {
        switch sheet {
        case .report(let report):
            ReportView(report: report)
        case .createSpending(let report):
            CreateSpendingView(report: report)
        case .doctorSelection(let date):
            DoctorSelectionView(date: date)
        case .doctorPayout(let doctor, let disabled, let isSinglePatient):
            DoctorPayoutView(doctor: doctor, disabled: disabled, isSinglePatient: isSinglePatient)
        case .doctorFutureSchedules(let doctorSchedule):
            DoctorFutureSchedulesView(doctorSchedule: doctorSchedule)
        case .addPatient(let appointment):
            AddPatientView(appointment: appointment)
        case .addProcedurePatient(let schedule):
            AddProcedurePatientView(schedule: schedule)
        case .completedAppointment(let appointment):
            CompletedAppointmentView(appointment: appointment)
        case .createBillTemplate(let services):
            CreateBillTemplateView(services: services)
        case .createDoctor:
            CreateDoctorView()
        case .createPricelistItem:
            CreatePricelistItemView()
        case .updateBalance(let person, let kind):
            UpdateBalanceView(person: person, kind: kind)
        case .billPayment(let person, let check, let isPaid):
            BillPaymentView(person: person, check: check, isPaid: isPaid)
        case .createNote(let kind):
            CreateNoteView(for: kind)
        case .accountDetail(let account):
            AccountTransactionsView(account: account)
        case .balanceDetail(let persons):
            BalanceDetailView(persons: persons)
        case .allTransactions:
            TransactionsView()
        }
    }
}
