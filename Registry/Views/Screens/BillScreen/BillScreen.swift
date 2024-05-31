//
//  BillScreen.swift
//  Registry
//
//  Created by Николай Фаустов on 26.02.2024.
//

import SwiftUI
import SwiftData

struct BillScreen: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext
    @Environment(\.servicesTablePurpose) private var servicesTablePurpose

    let appointment: PatientAppointment

    // MARK: - State

    @State private var isCompleted: Bool = false
    @State private var isPriselistPresented: Bool = false

    // MARK: -

    var body: some View {
        VStack(alignment: .leading) {
            if let patient = appointment.patient {
                LabeledContent {
                    if patient.balance != 0 {
                        Text("Баланс: \(Int(patient.balance)) ₽")
                            .foregroundStyle(patient.balance < 0 ? .red : .primary)
                    }
                } label: {
                    HStack {
                        Text(patient.fullName)
                            .font(.title3)
                            .padding(.horizontal)

                        if patient.currentTreatmentPlan != nil {
                            Image(systemName: "cross.case.circle")
                                .foregroundStyle(.orange)
                        }
                    }
                }
                .padding()
            }

            if let check = appointment.check {
                if let doctor = appointment.schedule?.doctor {
                    ServicesTable(doctor: doctor, check: check, editMode: $isPriselistPresented)
                        .servicesTablePurpose(servicesTablePurpose)
                        .background()
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                        .padding(.horizontal)
                }

                if servicesTablePurpose == .createAndPay, let patient = appointment.patient {
                    HStack(alignment: .bottom) {
                        PriceCalculationView(
                            patient: patient,
                            check: check
                        )
                        .disabled(paymentDisabled)
                    }
                    .padding([.horizontal, .bottom])
                    .frame(maxHeight: 140)
                }
            }
        }
        .navigationTitle("Счет")
        .navigationBarTitleDisplayMode(.inline)
        .sideSheet(isPresented: $isPriselistPresented) {
            PricelistSideSheetView()
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    NavigationStack {
        BillScreen(appointment: ExampleData.appointment)
            .environmentObject(Coordinator())
    }
    .previewInterfaceOrientation(.landscapeRight)
}

// MARK: - Calculations

private extension BillScreen {
    var paymentDisabled: Bool {
        guard let check = appointment.check else { return false }

        let isToday = Calendar.current.isDate(appointment.scheduledTime, inSameDayAs: .now)

        return !isToday || check.services.isEmpty
    }
}
