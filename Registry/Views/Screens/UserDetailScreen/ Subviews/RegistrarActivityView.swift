//
//  RegistrarActivityView.swift
//  Registry
//
//  Created by Николай Фаустов on 28.06.2024.
//

import SwiftUI

struct RegistrarActivityView: View {
    // MARK: - Dependencies

    @Environment(\.user) private var user
    @Environment(\.modelContext) private var modelContext

    // MARK: - State

    @State private var registrarActivity: [RegistrarActivity] = []
    @State private var isLoading: Bool = true
    @State private var showDetails: Bool = false

    // MARK: -

    var body: some View {
        Form {
            if let doctor = user as? Doctor {
                if !doctor.achievements.isEmpty {
                    Section("Достижения") {
                        ForEach(doctor.achievements.sorted(by: { $0.issueDate > $1.issueDate })) { achievement in
                            LabeledContent {
                                Text(achievement.period)
                            } label: {
                                Label {
                                    Text(achievement.kind.rawValue)
                                } icon: {
                                    Image(systemName: achievement.kind.icon)
                                        .foregroundStyle(.yellow)
                                }
                            }
                        }
                    }
                }

                Section("Активность регистраторов") {
                    if isLoading {
                        HStack {
                            Spacer()
                            CircularProgressView()
                            Spacer()
                        }
                    } else {
                        ForEach(registrarActivity, id: \.self) { activity in
                            Button {
                                showDetails = true
                            } label: {
                                LabeledContent {
                                    Text("\(activity.activity)")
                                        .font(.headline)
                                        .foregroundStyle(activity.registrar.id == user.id ? .primary : .secondary)
                                } label: {
                                    HStack {
                                        PersonImageView(person: activity.registrar)
                                            .frame(width: 60, height: 60, alignment: .top)
                                            .clipShape(Circle())
                                            .opacity(activity.registrar.id == user.id ? 1 : 0.75)

                                        Text(activity.registrar.fullName)
                                            .foregroundStyle(activity.registrar.id == user.id ? .primary : .secondary)
                                    }
                                }
                            }
                            .tint(.primary)
                            .disabled(activity.registrar.id != user.id)
                        }
                    }
                }
                .sheet(isPresented: $showDetails) {
                    NavigationStack {
                        let groupedAppointments = Dictionary(grouping: registrarAppointments(doctor), by: { Calendar.current.startOfDay(for: $0.scheduledTime) })
                        let sortedDates = groupedAppointments.keys.sorted(by: >)

                        List(sortedDates, id: \.self) { day in
                            DisclosureGroup {
                                let sortedDailyAppointments = groupedAppointments[day]?
                                    .sorted(by: { $0.registrationDate! < $1.registrationDate! }) ?? []
                                ForEach(sortedDailyAppointments, id: \.self) { appointment in
                                    if let patient = appointment.patient {
                                        LabeledContent {
                                            VStack(alignment: .trailing) {
                                                Text("Специалист \(appointment.schedule?.doctor?.initials ?? "")")
                                                HStack {
                                                    Text("Время приема")
                                                    DateText(appointment.scheduledTime, format: .time)
                                                }
                                            }
                                            .font(.subheadline)
                                        } label: {
                                            VStack(alignment: .leading) {
                                                HStack {
                                                    Text(appointment.patient?.initials ?? "")
                                                    Text("+\(patient.isNewPatient(for: day, period: .day) ? 3 : 2)")
                                                        .foregroundStyle(.green)
                                                }
                                                
                                                HStack {
                                                    Text("Регистрация")
                                                    DateText(appointment.registrationDate ?? .now, format: .date)
                                                }
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                            }
                                        }
                                    }
                                }
                            } label: {
                                DateText(day, format: .date)
                            }
                        }
                        .sheetToolbar("Активность", subtitle: doctor.initials)
                    }
                }
                .task {
                    let ledger = Ledger(modelContext: modelContext)
                    registrarActivity = ledger.registrarActivity(for: .now, period: .month)
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    RegistrarActivityView()
}

// MARK: - Claculations

private extension RegistrarActivityView {
    @MainActor
    func registrarAppointments(_ registrar: Doctor) -> [PatientAppointment] {
        let ledger = Ledger(modelContext: modelContext)
        return ledger.registrarAppointments(registrar, for: .now, period: .month)
    }
}
