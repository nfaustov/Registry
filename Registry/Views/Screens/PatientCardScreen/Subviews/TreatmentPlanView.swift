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
    @State private var treatmentPlanChecks: [Check]

    // MARK: -

    init(patient: Patient) {
        self.patient = patient
        _treatmentPlanChecks = State(initialValue: patient.treatmentPlanChecks)
    }

    var body: some View {
        Form {
            if let treatmentPlan = patient.currentTreatmentPlan {
                Section("Текущий лечебный план") {
                    if treatmentPlan.kind.isPregnancyAI {
                        Text(treatmentPlan.kind.rawValue)
                    } else {
                        LabeledContent(treatmentPlan.kind.rawValue) {
                            Text("активен до")
                            DateText(treatmentPlan.expirationDate, format: .date)
                        }
                    }
                }

                if treatmentPlan.kind.isPregnancyAI {
                    Button("Завершить", role: .destructive) {
                        treatmentPlan.complete()
                    }
                } else if !treatmentPlanChecks.isEmpty {
                    Section {
                        LabeledCurrency("Оплаты в рамках лечебного плана", value: totalChecksPrice)
                        LabeledCurrency("Цена без лечебного плана", value: treatmentPlanServicesBasePrice)
                        LabeledCurrency("Выгода", value: benefit)
                            .font(.headline)
                    }
                }
            } else {
                if patient.asDoctor == nil {
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

                    Section("Лечебные планы") {
                        ForEach(TreatmentPlan.Kind.allCases.filter { !$0.isPregnancyAI }, id: \.self) { kind in
                            treatmentPlanButton(treatmentPlanOfKind: kind)
                        }
                    }
                    Section("Ведение беременности") {
                        ForEach(TreatmentPlan.Kind.pregnancyAICases, id: \.self) { kind in
                            treatmentPlanButton(treatmentPlanOfKind: kind)
                        }
                    }
                } else {
                    Section("Лечебные планы") {
                        ForEach(TreatmentPlan.Kind.allCases.filter { !$0.isPregnancyAI }, id: \.self) { kind in
                            Button {
                                withAnimation {
                                    patient.activateTreatmentPlan(ofKind: kind)
                                }
                            } label: {
                                LabeledContent(kind.rawValue, value: "Активировать")
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

// MARK: - Subviews

private extension TreatmentPlanView {
    @ViewBuilder func treatmentPlanButton(treatmentPlanOfKind kind: TreatmentPlan.Kind) -> some View {
        if let pricelistItem = pricelistItem(forTreatmentPlanOfKind: kind) {
            Button {
                let appointment = createAppointment(with: pricelistItem)

                guard let check = appointment.check else { return }

                coordinator.present(
                    .billPayment(patient: patient, check: check, isPaid: $isPaid),
                    onDisappear: {
                        if isPaid {
                            withAnimation {
                                patient.activateTreatmentPlan(ofKind: kind)
                            }

                            if !kind.isPregnancyAI {
                                Task {
                                    await messageController.send(.treatmentPlanActivation(patient))
                                }
                            }
                        } else {
                            modelContext.delete(appointment)
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

// MARK: - Claculations

private extension TreatmentPlanView {
    var totalChecksPrice: Double {
        treatmentPlanChecks.reduce(0.0) { $0 + $1.price }
    }

    var treatmentPlanServicesBasePrice: Double {
        treatmentPlanChecks
            .flatMap { $0.services }
            .reduce(0.0) { $0 + $1.pricelistItem.price }
    }

    var benefit: Double {
        treatmentPlanServicesBasePrice - totalChecksPrice
    }

    func pricelistItem(forTreatmentPlanOfKind kind: TreatmentPlan.Kind) -> PricelistItem? {
        let id = kind.id
        let predicate = #Predicate<PricelistItem> { $0.id == id }
        let database = DatabaseController(modelContext: modelContext)

        return database.getModel(predicate: predicate)
    }

    func createAppointment(with pricelistItem: PricelistItem) -> PatientAppointment {
        let medicalService = MedicalService(pricelistItem: pricelistItem.snapshot, agent: agent)
        let check = Check(services: [medicalService])
        let appointment = PatientAppointment(scheduledTime: .now, duration: 0)
        appointment.registerPatient(
            patient,
            duration: 0,
            registrar: user.asAnyUser,
            mergedCheck: check
        )

        return appointment
    }
}
