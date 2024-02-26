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
        }
    }

    @ViewBuilder func destinationView(_ route: Route) -> some View {
        switch route {
        case .appointments:
            AppointmentsRegisterScreen()
        case .doctorDetail(let doctor):
            DoctorDetailScreen(doctor: doctor)
        case .patientCard(let patient):
            PatientCardScreen(patient: patient)
        default: EmptyView()
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
        case .doctorPayout(let doctor):
            DoctorPayoutView(doctor: doctor)
        case .doctorFutureSchedules(let doctorSchedule):
            DoctorFutureSchedulesView(doctorSchedule: doctorSchedule)
        case .addPatient(let appointment):
            AddPatientView(appointment: appointment)
        case .createDoctor:
            CreateDoctorView()
        case .createPatient:
            CreatePatientView()
        case .createPricelistItem:
            CreatePricelistItemView()
        default: EmptyView()
        }
    }
}
