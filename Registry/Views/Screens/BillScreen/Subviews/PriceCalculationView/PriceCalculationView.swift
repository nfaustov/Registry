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
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var coordinator: Coordinator

    let patient: Patient
    @Bindable var check: Check

    // MARK: - State

    @State private var addDiscount: Bool = false
    @State private var payBill: Bool = false
    @State private var showDiscountSheet: Bool = false
    @State var isPaid: Bool = false

    // MARK: -

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                HStack {
                    Text(check.discount > 0 ? "Промежуточный итог:" : "Итог:")
                        .font(.headline)
                    Spacer()
                    CurrencyText(check.price)
                        .font(.title3)
                }

                if patient.balance != 0 {
                    HStack {
                        Text(patient.balance > 0 ? "С баланса:" : "Долг:")
                            .font(.headline)
                        Spacer()
                        CurrencyText(-balancePayment)
                            .font(.title3)
                    }
                }

                if check.discount > 0 {
                    HStack {
                        Text("Скидка (\(discountPercent)%):")
                            .font(.headline)
                        Spacer()
                        CurrencyText(-check.discount)
                            .font(.title3)
                    }
                }

                HStack {
                    Button {
                        coordinator.present(
                            .billPayment(
                                patient: patient,
                                check: check,
                                isPaid: $isPaid
                            ),
                            onDisappear: { if isPaid { dismiss() } }
                        )
                    } label: {
                        CurrencyText(check.totalPrice - balancePayment)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 28)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        addDiscount = true
                    } label: {
                        Text("Cкидка")
                            .frame(width: 80, height: 28)
                    }
                    .buttonStyle(.bordered)
                    .disabled(patient.currentTreatmentPlan != nil)
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
                                MoneyFieldSection(value: $check.discount)
                            }
                            .sheetToolbar("Сумма скидки")
                        }
                    }
                }
            }
            .frame(width: 500)
        }
    }
}

#Preview {
    PriceCalculationView(
        patient: ExampleData.patient,
        check: Check(services: [])
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
    var discountPercent: Int {
        Int(check.discountRate * 100)
    }

    var balancePayment: Double {
        patient.balance > check.totalPrice ? check.totalPrice : patient.balance
    }
}
