//
//  AppointmentsListView.swift
//  Registry
//
//  Created by Николай Фаустов on 25.02.2024.
//

import SwiftUI

struct AppointmentsListView: View {
    // MARK: - Dependencies

    @EnvironmentObject private var coordinator: Coordinator

    @Bindable var schedule: DoctorSchedule

    // MARK: -

    var body: some View {
        List(scheduleAppointments) { appointment in
            AppointmentView(appointment: appointment)
                .swipeActions(edge: .trailing) {
                    if scheduleAppointments.count > 1 {
                        trailingSwipeActions(for: appointment)
                    }
                }
                .swipeActions(edge: .leading) {
                    leadingSwipeActions(for: appointment)
                }
                .contextMenu {
                    if !isExpiredForUpdating {
                        menuView(for: appointment)
                    }
                }
                .disabled(isExpiredForUpdating)
        }
        .listStyle(.plain)
        .scrollBounceBehavior(.basedOnSize)
    }
}

#Preview {
    AppointmentsListView(schedule: ExampleData.doctorSchedule)
}

// MARK: - Calculations

private extension AppointmentsListView {
    var scheduleAppointments: [PatientAppointment] {
        schedule.patientAppointments?
            .sorted(by: { $0.scheduledTime < $1.scheduledTime }) ?? []
    }

    var isAvailableToExtendStarting: Bool {
        schedule.starting.addingTimeInterval(-(schedule.doctor?.serviceDuration ?? 0)) >=
        WorkingHours(for: schedule.starting).start && (schedule.patientAppointments?.count ?? 0) > 1
    }

    var isAvailableToExtendEnding: Bool {
        schedule.ending.addingTimeInterval(schedule.doctor?.serviceDuration ?? 0) <=
        WorkingHours(for: schedule.starting).end
    }

    var isExpiredForUpdating: Bool {
        schedule.starting < Calendar.current.startOfDay(for: .now)
    }
}

// MARK: - Subviews

private extension AppointmentsListView {
    @ViewBuilder func menuView(for appointment: PatientAppointment) -> some View {
        if let patient = appointment.patient, appointment.status != .completed {
            Section {
                Button {
                    coordinator.push(.bill(for: appointment))
                } label: {
                    Label("Счет", systemImage: "list.bullet.rectangle.portrait")
                }

                Button {
                    coordinator.push(.patientCard(patient))
                } label: {
                    Label("Карта пациента", systemImage: "info.circle")
                }
            }

            Section {
                Button(role: .destructive) {
                    if patient.mergedAppointments(forAppointmentID: appointment.id).count == 1 {
                        patient.cancelVisit(for: appointment.id)
                        schedule.cancelPatientAppointment(appointment)
                    } else if let visit = patient.visit(forAppointmentID: appointment.id) {
                        schedule.cancelPatientAppointment(appointment)
                        patient.specifyVisitDate(visit.id)
                    }
                } label: {
                    Label("Отменить прием", systemImage: "person.badge.minus")
                }
            }
        }
    }

    @ViewBuilder func trailingSwipeActions(for appointment: PatientAppointment) -> some View {
        if scheduleAppointments.first == appointment, appointment.patient == nil {
            removeAppointmentButton(at: .starting)
        }
        if scheduleAppointments.last == appointment, appointment.patient == nil {
            removeAppointmentButton(at: .ending)
        }
    }

    @ViewBuilder func leadingSwipeActions(for appointment: PatientAppointment) -> some View {
        if scheduleAppointments.first == appointment, isAvailableToExtendStarting {
            extendSchehuleButton(at: .starting)
        }
        if scheduleAppointments.last == appointment, isAvailableToExtendEnding {
            extendSchehuleButton(at: .ending)        }
    }

    func extendSchehuleButton(at edge: ScheduleEdge) -> some View {
        Button {
            let scheduledTime = edge == .starting ? schedule.starting.addingTimeInterval(-(schedule.doctor?.serviceDuration ?? 0)) : schedule.ending

            let appointment = PatientAppointment(
                scheduledTime: scheduledTime,
                duration: schedule.doctor?.serviceDuration ?? 0,
                patient: nil
            )
            schedule.patientAppointments?.append(appointment)

            switch edge {
            case .starting:
                schedule.starting.addTimeInterval(-appointment.duration)
            case .ending:
                schedule.ending.addTimeInterval(appointment.duration)
            }
            
        } label: {
            Label("Добавить время", systemImage: "plus.circle.fill")
        }
        .tint(.green)
    }

    func removeAppointmentButton(at edge: ScheduleEdge) -> some View {
        Button(role: .destructive) {
            switch edge {
            case .starting:
                if let appointment = scheduleAppointments.first {
                    schedule.patientAppointments?.removeAll(where: { $0 == appointment })
                    schedule.starting.addTimeInterval(appointment.duration)
                }
            case .ending:
                if let appointment = scheduleAppointments.last {
                    schedule.patientAppointments?.removeAll(where: { $0 == appointment })
                    schedule.ending.addTimeInterval(-appointment.duration)
                }
            }
        } label: {
            Label("Удалить ячейку", systemImage: "trash")
        }
    }
}
