//
//  AddTreatmentPlanView.swift
//  Registry
//
//  Created by Николай Фаустов on 24.05.2024.
//

import SwiftUI
import SwiftData

struct AddTreatmentPlanView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.user) private var user

    @EnvironmentObject private var coordinator: Coordinator

    @Query private var doctors: [Doctor]

    let patient: Patient

    // MARK: - State

    @State private var agent: Doctor?
    @State private var check: Check?
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
                                check = Check(services: [medicalService])
                                coordinator.present(.billPayment(patient: patient, check: check!, isPaid: $isPaid))
                            } label: {
                                LabeledCurrency(kind.rawValue, value: pricelistItem.price)
                            }
                            .buttonStyle(.plain)
                            .onChange(of: isPaid) { _, newValue in
                                if newValue {
                                    if let check {
                                        let appointment = PatientAppointment(scheduledTime: .now, duration: 0)
                                        appointment.registerPatient(patient, duration: 0, registrar: user.asAnyUser)
                                        appointment.check = check
                                        appointment.status = .completed
                                        patient.activateTreatmentPlan(ofKind: kind)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    AddTreatmentPlanView(patient: ExampleData.patient)
}

// MARK: - Claculations

private extension AddTreatmentPlanView {
    func pricelistItem(forTreatmentPlanOfKind kind: TreatmentPlan.Kind) -> PricelistItem? {
        let id = kind.id
        let predicate = #Predicate<PricelistItem> { $0.id == id }
        let descriptor = FetchDescriptor(predicate: predicate)

        return try? modelContext.fetch(descriptor).first
    }
}
