//
//  TreatmentPlanView.swift
//  Registry
//
//  Created by Николай Фаустов on 24.05.2024.
//

import SwiftUI
import SwiftData

struct TreatmentPlanView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext
    @Environment(\.user) private var user

    @StateObject private var messageController = MessageController()

    @EnvironmentObject private var coordinator: Coordinator

    @Query private var doctors: [Doctor]

    let patient: Patient

    // MARK: - State

    @State private var agent: Doctor?
    @State private var isPaid: Bool = false

    // MARK: -

    var body: some View {
        Form {
            if let treatmentPlan = patient.treatmentPlan {
                Section("Текущий лечебный план") {
                    LabeledContent(treatmentPlan.kind.rawValue) {
                        Text("активен до")
                        DateText(treatmentPlan.expirationDate, format: .date)
                    }
                }

                Section {
                    Button("Удалить", role: .destructive) {
                        patient.treatmentPlan = nil
                    }
                }
            } else {
                Section {
                    LabeledContent("Врач") {
                        Menu(agent?.initials ?? "Выберите врача") {
                            Button("-") {
                                agent = nil
                            }
                            ForEach(doctors) { doctor in
                                Button(doctor.initials) {
                                    agent = doctor
                                }
                            }
                        }
                    }
                }

                Section {
                    ForEach(TreatmentPlan.Kind.allCases, id: \.self) { kind in
                        if let pricelistItem = pricelistItem(forTreatmentPlanOfKind: kind) {
                            Button {
                                let medicalService = MedicalService(pricelistItem: pricelistItem.snapshot, agent: agent)
                                let check = Check(services: [medicalService])
                                modelContext.insert(check)

                                coordinator.present(
                                    .billPayment(patient: patient, check: check, isPaid: $isPaid),
                                    onDisappear: {
                                        if isPaid {
                                            let appointment = PatientAppointment(scheduledTime: .now, duration: 0)
                                            appointment.registerPatient(patient, duration: 0, registrar: user.asAnyUser)
                                            appointment.check = check
                                            appointment.status = .completed

                                            withAnimation {
                                                patient.activateTreatmentPlan(ofKind: kind)
                                            }

//                                            Task {
//                                                await messageController.send(.treatmentPlanActivation(patient))
//                                            }
                                        } else {
                                            modelContext.delete(check)
                                        }
                                    }
                                )
                            } label: {
                                LabeledCurrency(kind.rawValue, value: pricelistItem.price)
                            }
                            .tint(.primary)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    TreatmentPlanView(patient: ExampleData.patient)
}

// MARK: - Claculations

private extension TreatmentPlanView {
    func pricelistItem(forTreatmentPlanOfKind kind: TreatmentPlan.Kind) -> PricelistItem? {
        let id = kind.id
        let predicate = #Predicate<PricelistItem> { $0.id == id }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1

        return try? modelContext.fetch(descriptor).first
    }
}
