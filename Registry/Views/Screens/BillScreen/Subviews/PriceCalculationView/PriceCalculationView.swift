//
//  PriceCalculationView.swift
//  Registry
//
//  Created by Николай Фаустов on 27.02.2024.
//

import SwiftUI

struct PriceCalculationView: View {
    // MARK: - Dependencies

    @Environment(\.user) private var user

    @EnvironmentObject private var coordinator: Coordinator

    let appointment: PatientAppointment
    @Bindable var check: Check
    @Binding var isCompleted: Bool

    // MARK: - State

    @State private var addDiscount: Bool = false
    @State private var payBill: Bool = false
    @State private var showDiscountSheet: Bool = false

    // MARK: -

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                HStack {
                    Text(check.discount > 0 ? "Промежуточный итог:" : "Итог:")
                        .font(.headline)
                    Spacer()
                    Text("\(Int(check.price)) ₽")
                        .font(.title3)
                }

                if patient.balance != 0 {
                    HStack {
                        Text(isCompleted ? "Баланс:" : patient.balance > 0 ? "С баланса:" : "Долг:")
                            .font(.headline)
                        Spacer()
                        Text(isCompleted ? "\(Int(patient.balance)) ₽" : "\(-Int(patient.balance)) ₽")
                            .font(.title3)
                    }
                }

                if check.discount > 0 {
                    HStack {
                        Text("Скидка (\(discountPercent)%):")
                            .font(.headline)
                        Spacer()
                        Text("\(-Int(check.discount)) ₽")
                            .font(.title3)
                    }
                }

                HStack {
                    Button {
                        patient.updateCheck(check, forAppointmentID: appointment.id)
                        coordinator.present(
                            .billPayment(
                                appointment: appointment,
                                isPaid: $isCompleted
                            )
                        )
                    } label: {
                        Text("₽ \(Int(isCompleted ? check.totalPrice + patient.balance : check.totalPrice - patient.balance))")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 28)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!Calendar.current.isDate(appointment.scheduledTime, inSameDayAs: .now))

                    Button {
                        addDiscount = true
                    } label: {
                        Text("Cкидка")
                            .frame(width: 80, height: 28)
                    }
                    .buttonStyle(.bordered)
                    .confirmationDialog("Скидка", isPresented: $addDiscount) {
                        discountButton(3)
                        discountButton(5)
                        discountButton(7)
                        discountButton(10)

                        if user.accessLevel == .boss {
                            Button("Ввести сумму") {
                                showDiscountSheet = true
                            }
                        }

                        Button("Отменить", role: .destructive) {
                            check.discount = 0
                        }
                    }
                    .sheet(isPresented: $showDiscountSheet) {
                        NavigationStack {
                            Form {
                                TextField("Сумма скидки", value: $check.discount, format: .number)
                            }
                            .sheetToolbar(title: "Сумма скидки")
                        }
                    }
                }
            }
            .frame(width: 500)
        }
        .onDisappear {
            if !isCompleted {
                patient.updateCheck(check, forAppointmentID: appointment.id)
            }
        }
    }
}

#Preview {
    PriceCalculationView(
        appointment: ExampleData.appointment,
        check: Check(services: []),
        isCompleted: .constant(false)
    )
    .environmentObject(Coordinator())
}

// MARK: - Subviews

private extension PriceCalculationView {
    @ViewBuilder func discountButton(_ percent: Double) -> some View {
        let discount = check.price * percent / 100
        Button("\(Int(percent))% (\(Int(discount.rounded())) ₽)") {
            check.discount = discount.rounded()
        }
    }
}

// MARK: - Calculations

private extension PriceCalculationView {
    var patient: Patient {
        guard let patient = appointment.patient else { fatalError() }
        return patient
    }

    var discountPercent: Int {
        Int(check.discountRate * 100)
    }
}
