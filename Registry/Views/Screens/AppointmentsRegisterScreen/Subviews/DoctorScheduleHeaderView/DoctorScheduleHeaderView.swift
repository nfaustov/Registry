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
        HStack(alignment: .bottom, spacing: 0) {
            if let doctor = doctorSchedule.doctor {
                PersonImageView(person: doctor)
                    .frame(width: 120, height: 150, alignment: .top)
                    .clipped()
                    .cornerRadius(12)

                VStack(alignment: .leading) {
                    Text(doctor.fullName)
                        .font(.title3).bold()
                    Text(doctor.department.specialization)
                        .padding(.bottom, 4)

                    Spacer()

                    Label(" \(doctorSchedule.cabinet)", systemImage: "door.left.hand.closed")
                        .padding(.bottom, 4)

                    Label(duration, systemImage: "timer")
                        .padding(.bottom, 4)

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

                controlsStackView
                    .padding(.horizontal)
            }
        }
    }
}

#Preview {
    DoctorScheduleHeaderView(doctorSchedule: ExampleData.doctorSchedule, deleteSchedule: { })
        .frame(height: 150)
        .environmentObject(Coordinator())
}

// MARK: - Calculations

private extension DoctorScheduleHeaderView {
    var incompletedAppointments: Int {
        doctorSchedule.scheduledPatients.count - doctorSchedule.completedAppointments.count
    }

    var isSinglePatient: Bool {
        doctorSchedule.scheduledPatients.count == 1 && doctorSchedule.completedAppointments.count == 1
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
}

// MARK: - Subviews

private extension DoctorScheduleHeaderView {
    var controlsStackView: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if let doctor = doctorSchedule.doctor {
                Button {
                    if doctor.department == .procedure {
                        coordinator.present(.updateBalance(for: doctor, kind: .payout))
                    } else {
                        coordinator.present(.doctorPayout(for: doctor, disabled: incompletedAppointments > 0, isSinglePatient: isSinglePatient))
                    }
                } label: {
                    buttonImage("rublesign.circle")
                }
                .buttonStyle(ColoredIconButtonStyle(color: .purple))
                .disabled(!Calendar.current.isDateInToday(doctorSchedule.starting))

                if doctor.department != .procedure {
                    Button {
                        coordinator.present(.doctorFutureSchedules(doctorSchedule: doctorSchedule))
                    } label: {
                        buttonImage("calendar")
                    }
                    .buttonStyle(ColoredIconButtonStyle(color: .cyan))
                }

                Button {
                    coordinator.present(.createNote(for: .doctorSchedule(doctorSchedule)))
                } label: {
                    buttonImage(doctorSchedule.note == nil ? "note.text.badge.plus" : "note.text")
                }
                .buttonStyle(ColoredIconButtonStyle(color: .indigo))
                .disabled(doctorSchedule.starting < Calendar.current.startOfDay(for: .now))

                Button {
                    deleteSchedule()
                } label: {
                    buttonImage("trash")
                }
                .buttonStyle(ColoredIconButtonStyle(color: .red))
                .disabled(doctorSchedule.scheduledPatients.count > 0)
            }
        }
    }

    func buttonImage(_ systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.title2)
    }
}
