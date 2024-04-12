//
//  AppointmentsListView.swift
//  Registry
//
//  Created by Николай Фаустов on 25.02.2024.
//

import SwiftUI

struct AppointmentsListView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject private var coordinator: Coordinator

    @StateObject private var messageController = MessageController()

    @Bindable var schedule: DoctorSchedule

    // MARK: -

    var body: some View {
        List {
            if schedule.doctor?.department == .procedure {
                HStack {
                    Spacer()

                    Button {
                        coordinator.present(.addProcedurePatient(for: schedule))
                    } label: {
                        Image(systemName: "person.crop.rectangle.badge.plus")
                            .padding(12)
                    }
                    .buttonStyle(.bordered)
                }
            }
            ForEach(scheduleAppointments) { appointment in
                AppointmentView(appointment: appointment)
                    .swipeActions(edge: .trailing) {
                        if scheduleAppointments.count > 1 {
                            trailingSwipeActions(for: appointment)
                                .disabled(schedule.doctor?.department == .procedure)
                        }
                    }
                    .swipeActions(edge: .leading) {
                        leadingSwipeActions(for: appointment)
                            .disabled(schedule.doctor?.department == .procedure || isExpiredForUpdating)
                    }
                    .contextMenu {
                        if !isExpiredForUpdating {
                            menuView(for: appointment)
                        }
                    }
                    .alert(
                        "Не удалось отправить SMS",
                        isPresented: $messageController.showErrorMessage,
                        presenting: messageController.errorMessage
                    ) { _ in 
                        Button("Ok") { messageController.showErrorMessage = false }
                    } message: { Text($0) }
                    
            }
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

    func disableNotification(for appointment: PatientAppointment) -> Bool {
        guard appointment.scheduledTime > .now, let patient = appointment.patient else { return true }
        return patient.phoneNumber.count != 18
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

            if appointment.status == .registered {
                Section {
                    Button {
                        Task {
                            await messageController.send(.appointmentReminder(appointment))

                            if !messageController.showErrorMessage {
                                appointment.status = .notified
                            }
                        }
                    } label: {
                        Label("Отправить SMS", systemImage: "arrow.up.message")
                    }
                    .disabled(disableNotification(for: appointment))
                }
            }

            Section {
                Button(role: .destructive) {
                    withAnimation {
                        if schedule.doctor?.department == .procedure {
                            if patient.mergedAppointments(forAppointmentID: appointment.id).count == 1 {
                                patient.cancelVisit(for: appointment.id)
                                schedule.patientAppointments?.removeAll(where: { $0.id == appointment.id })
                            } else if let visit = patient.visit(forAppointmentID: appointment.id) {
                                schedule.patientAppointments?.removeAll(where: { $0.id == appointment.id })
                                patient.specifyVisitDate(visit.id)
                            }
                        } else {
                            if patient.mergedAppointments(forAppointmentID: appointment.id).count == 1 {
                                patient.cancelVisit(for: appointment.id)
                                schedule.cancelPatientAppointment(appointment)
                            } else if let visit = patient.visit(forAppointmentID: appointment.id) {
                                schedule.cancelPatientAppointment(appointment)
                                patient.specifyVisitDate(visit.id)
                            }
                        }
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
