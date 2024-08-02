//
//  RegistrarsReportingView.swift
//  Registry
//
//  Created by Николай Фаустов on 13.06.2024.
//

import SwiftUI

struct RegistrarsReportingView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    let date: Date
    let selectedPeriod: StatisticsPeriod

    // MARK: - State

    @State private var selectedRegistrar: Doctor?

    // MARK: -

    var body: some View {
        GroupBox("Активность регистраторов") {
            if registrarActivity.isEmpty {
                ContentUnavailableView("Нет данных", systemImage: "tray")
            } else {
                ForEach(registrarActivity, id: \.self) { activity in
                    Button {
                        selectedRegistrar = activity.registrar
                    } label: {
                        LabeledContent {
                            Text("\(activity.activity)")
                                .fontWeight(.medium)
                        } label: {
                            HStack {
                                PersonImageView(person: activity.registrar)
                                    .frame(width: 44, height: 44, alignment: .top)
                                    .clipShape(Circle())

                                Text(activity.registrar.fullName)
                                    .lineLimit(2)
                            }
                        }
                    }
                    .tint(.primary)
                }
            }
        }
        .groupBoxStyle(.reporting)
        .sheet(item: $selectedRegistrar) { registrar in
            NavigationStack {
                let groupedAppointments = Dictionary(grouping: registrarAppointments(registrar), by: { Calendar.current.startOfDay(for: $0.scheduledTime) })
                let sortedDates = groupedAppointments.keys.sorted(by: >)

                List(sortedDates, id: \.self) { day in
                    DisclosureGroup {
                        let sortedDailyAppointments = groupedAppointments[day]?
                            .sorted(by: { $0.registrationDate! < $1.registrationDate! }) ?? []
                        ForEach(sortedDailyAppointments, id: \.self) { appointment in
                            LabeledContent {
                                VStack(alignment: .trailing) {
                                    Text("Специалист \(appointment.schedule?.doctor?.initials ?? "")")
                                    HStack {
                                        Text("Время приема")
                                        DateText(appointment.scheduledTime, format: .time)
                                    }
                                    .font(.subheadline)
                                }
                            } label: {
                                Text(appointment.patient?.initials ?? "")
                                HStack {
                                    Text("Регистрация")
                                    DateText(appointment.registrationDate ?? .now, format: .date)
                                }
                            }
                        }
                    } label: {
                        DateText(day, format: .date)
                    }
                }
                .sheetToolbar("Активность", subtitle: registrar.initials)
            }
        }
    }
}

#Preview {
    RegistrarsReportingView(date: .now, selectedPeriod: .day)
}

// MARK: - Calculations

private extension RegistrarsReportingView {
    @MainActor
    var registrarActivity: [RegistrarActivity] {
        let ledger = Ledger(modelContext: modelContext)
        return ledger.registrarActivity(for: date, period: selectedPeriod)
    }

    @MainActor
    func registrarAppointments(_ registrar: Doctor) -> [PatientAppointment] {
        let ledger = Ledger(modelContext: modelContext)
        return ledger.registrarAppointments(registrar, for: date, period: selectedPeriod)
    }
}
