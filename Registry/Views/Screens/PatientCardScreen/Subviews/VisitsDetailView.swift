//
//  VisitsDetailView.swift
//  Registry
//
//  Created by Николай Фаустов on 21.02.2024.
//

import SwiftUI
import Algorithms

struct VisitsDetailView: View {
    // MARK: - Dependencies

    @EnvironmentObject private var coordinator: Coordinator

    let patient: Patient

    // MARK: -

    var body: some View {
        List {
            ForEach(uniqueDates, id: \.self) { date in
                Section {
                    let visits = patient.appointments?.filter {
                        Calendar.current.isDate($0.scheduledTime, inSameDayAs: date)
                    }
                    ForEach(visits ?? []) { visit in
                        visitView(visit)
                    }
                } header: {
                    DateText(date, format: .weekDay)
                }
            }
        }
    }
}

#Preview {
    VisitsDetailView(patient: ExampleData.patient)
        .environmentObject(Coordinator())
}

// MARK: - Calculations

private extension VisitsDetailView {
    var uniqueDates: [Date] {
        if let appointments = patient.appointments {
            return Array(
                appointments
                    .map { Calendar.current.dateComponents([.year, .month, .day], from: $0.scheduledTime) }
                    .map { Calendar.current.date(from: $0)! }
                    .uniqued()
            )
            .sorted(by: >)
        } else { return [] }
    }

    func uniqueDoctors(from check: Check) -> [Doctor] {
        let doctors = check.services.compactMap { $0.performer }
        return Array(doctors.uniqued())
    }
}

// MARK: - Subviews

private extension VisitsDetailView {
    func visitView(_ appointment: PatientAppointment) -> some View {
        Section {
            if let check = appointment.check, check.payment != nil {
                if !check.services.isEmpty {
                    DisclosureGroup {
                        ForEach(check.services) { service in
                            LabeledCurrency(service.title, value: service.price)
                        }

                        if check.discount > 0 {
                            LabeledCurrency("Скидка", value: -check.discount)
                                .foregroundStyle(.blue)
                                .fontWeight(.light)
                        }
                    } label: {
                        LabeledCurrency("Счет", value: check.totalPrice)
                            .font(.headline)
                            .foregroundStyle(.blue)
                    }
                }

                if let refund = check.refund {
                    DisclosureGroup {
                        ForEach(refund.services) { service in
                            LabeledCurrency(service.title, value: service.price)
                        }
                    } label: {
                        LabeledCurrency("Возврат", value: -refund.totalAmount)
                            .font(.headline)
                            .foregroundStyle(.red)
                    }
                    .tint(.red)
                }

                if check.refund == nil, !check.services.isEmpty {
                    if check.payment != nil {
                        Button {
                            coordinator.push(.contract(for: patient, check: check))
                        } label: {
                            Label("Договор", systemImage: "doc.text")
                                .tint(.primary)
                        }
                    }

                    let uniqueDoctors = uniqueDoctors(from: check)

                    if uniqueDoctors.count > 0 {
                        HStack {
                            Text(uniqueDoctors.count > 1 ? "Специалисты:" : "Специалист:")
                                .font(.headline)

                            ForEach(uniqueDoctors) { doctor in
                                Text(doctor.initials)
                                    .foregroundStyle(.white)
                                    .padding(4)
                                    .background(.teal)
                                    .clipShape(.rect(cornerRadius: 4, style: .continuous))
                            }
                        }
                    }
                }
            }

            if let registrationDate = appointment.registrationDate {
                LabeledContent("Дата регистрации") {
                    DateText(registrationDate, format: .dateTime)
                }
            }

            if let registrar = appointment.registrar {
                LabeledContent("Регистратор", value: registrar.initials)
            }
        } header: {
            DateText(appointment.scheduledTime, format: .time)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
}
