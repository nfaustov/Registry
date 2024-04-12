//
//  DoctorScheduleHeaderView.swift
//  Registry
//
//  Created by Николай Фаустов on 23.02.2024.
//

import SwiftUI

struct DoctorScheduleHeaderView: View {
    // MARK: - Dependencies

    @EnvironmentObject private var coordinator: Coordinator

    let doctorSchedule: DoctorSchedule
    let deleteSchedule: () -> Void

    // MARK: -

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if let doctor = doctorSchedule.doctor {
                PersonImageView(person: doctor)
                    .frame(width: isPhoneUserInterfaceIdiom ? 80 : 120, height: isPhoneUserInterfaceIdiom ? 100 : 150, alignment: .top)
                    .clipped()
                    .cornerRadius(12)

                VStack(alignment: .leading) {
                    Text(isPhoneUserInterfaceIdiom ? doctor.initials : doctor.fullName)
                        .font(.title3).bold()
                    Text(doctor.department.specialization)
                        .padding(.bottom, 4)

                    if !isPhoneUserInterfaceIdiom {
                        Spacer()
                    }

                    if isPhoneUserInterfaceIdiom {
                        HStack(spacing: 20) {
                            Label("  \(doctorSchedule.cabinet)", systemImage: "door.left.hand.closed")
                            Label(duration, systemImage: "timer")
                        }
                        .padding(.bottom, 4)
                    } else {
                        Label(" \(doctorSchedule.cabinet)", systemImage: "door.left.hand.closed")
                            .padding(.bottom, 4)

                        Label(duration, systemImage: "timer")
                            .padding(.bottom, 4)
                    }

                    HStack {
                        if !doctorSchedule.completedAppointments.isEmpty {
                            Label("\(doctorSchedule.completedAppointments.count)", systemImage: "person.fill.checkmark")
                            Divider()
                        }

                        Label("\(incompletedAppointments)", systemImage: "person.badge.clock.fill")

                        if doctorSchedule.availableAppointments > 0 {
                            Divider()
                            Label("\(doctorSchedule.availableAppointments)", systemImage: "person")
                        }
                    }
                    .frame(height: 20)
                }
                .font(.subheadline)
                .padding(.horizontal)

                Spacer()

                Menu {
                    Section {
                        Button("Выплата") {
                            if doctor.department == .procedure {
                                coordinator.present(
                                    .updateBalance(
                                        for: Binding(get: { doctor }, set: { value in doctor.balance = value.balance }),
                                        kind: .payout
                                    )
                                )
                            } else {
                                coordinator.present(.doctorPayout(for: doctor, disabled: incompletedAppointments > 0))
                            }
                        }
                        .disabled(!Calendar.current.isDateInToday(doctorSchedule.starting))

                        if doctor.department != .procedure {
                            Button("Расписания врача") {
                                coordinator.present(.doctorFutureSchedules(doctorSchedule: doctorSchedule))
                            }
                        }
                    }

                    Button("Удалить расписание", role: .destructive) {
                        deleteSchedule()
                    }
                    .disabled(doctorSchedule.scheduledPatients.count > 0)
                } label: {
                    Label("Действия", systemImage: "ellipsis.circle")
                }
            }
        }
    }
}

#Preview {
    DoctorScheduleHeaderView(doctorSchedule: ExampleData.doctorSchedule, deleteSchedule: { })
        .frame(height: 150)
}

// MARK: - Calculations

private extension DoctorScheduleHeaderView {
    var incompletedAppointments: Int {
        doctorSchedule.scheduledPatients.count - doctorSchedule.completedAppointments.count
    }

    var duration: String {
        guard let doctor = doctorSchedule.doctor else { return "" }
        let hours = Int(doctor.serviceDuration / 3600)
        let minutes = (Int(doctor.serviceDuration) % 3600) / 60

        var result = hours > 0 ? "\(hours) ч. " : ""

        if minutes > 0 {
            result += "\(minutes) мин."
        }

        return result
    }

    var isPhoneUserInterfaceIdiom: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}
