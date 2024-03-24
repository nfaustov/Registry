//
//  Coordinator.swift
//  Registry
//
//  Created by Николай Фаустов on 22.12.2023.
//

import SwiftUI

final class Coordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var sheet: Sheet? = nil

    func push(_ route: Route) {
        path.append(route)
    }

    func present(_ sheet: Sheet) {
        self.sheet = sheet
    }

    func pop() {
        path.removeLast()
    }

    func clearPath() {
        path.removeLast(path.count)
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
        case .indicators:
            IndicatorsScreen()
        }
    }

    @ViewBuilder func destinationView(_ route: Route) -> some View {
        switch route {
        case .appointments:
            AppointmentsRegisterScreen()
        case .bill(let appointment):
            BillScreen(appointment: appointment)
        case .doctorDetail(let doctor):
            DoctorDetailScreen(doctor: doctor)
        case .patientCard(let patient):
            PatientCardScreen(patient: patient)
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
        case .doctorPayout(let doctor, let disabled):
            DoctorPayoutView(doctor: doctor, disabled: disabled)
        case .doctorFutureSchedules(let doctorSchedule):
            DoctorFutureSchedulesView(doctorSchedule: doctorSchedule)
        case .addPatient(let appointment):
            AddPatientView(appointment: appointment)
        case .completedAppointment(let appointment):
            CompletedAppointmentView(appointment: appointment)
        case .createBillTemplate(let services):
            CreateBillTemplateView(services: services)
        case .createDoctor:
            CreateDoctorView()
        case .createPatient:
            CreatePatientView()
        case .createPricelistItem:
            CreatePricelistItemView()
        case .billPayment(let appointment, let isPaid):
            BillPaymentView(appointment: appointment, isPaid: isPaid)
        }
    }
}
