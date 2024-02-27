//
//  PriceCalculationView.swift
//  Registry
//
//  Created by Николай Фаустов on 27.02.2024.
//

import SwiftUI

struct PriceCalculationView: View {
    // MARK: - Dependencies

    @EnvironmentObject private var coordinator: Coordinator

    let appointment: PatientAppointment
    @Binding var bill: Bill
    @Binding var includeBalance: Bool
    @Binding var isCompleted: Bool

    // MARK: - State

    @State private var addDiscount: Bool = false
    @State private var payBill: Bool = false
    @State private var discountPercent: Int = 0

    // MARK: -

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(bill.discount > 0 || includeBalance ? "Промежуточный итог:" : "Итог:")
                        .font(.headline)
                    Spacer()
                    Text("\(Int(bill.price)) ₽")
                        .font(.title3)
                }

                if includeBalance {
                    HStack {
                        Text(patient.balance > 0 ? "С баланса:" : "На баланс:")
                            .font(.headline)
                        Spacer()
                        Text("\(-Int(patient.balance)) ₽")
                            .font(.title3)
                    }
                }

                if bill.discount > 0 {
                    HStack {
                        Text("Скидка (\(discountPercent)%):")
                            .font(.headline)
                        Spacer()
                        Text("\(-Int(bill.discount)) ₽")
                            .font(.title3)
                    }
                }

                HStack {
                    Button {
                        coordinator.present(
                            .billPayment(
                                appointment: appointment,
                                includedPatientBalance: includeBalance ? patient.balance : 0,
                                bill: bill,
                                isPaid: $isCompleted
                            )
                        )
                    } label: {
                        let balancePayment = includeBalance ? patient.balance : 0
                        Text("₽ \(Int(bill.totalPrice - balancePayment))")
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

                        Button("Отменить", role: .destructive) {
                            bill.discount = 0
                            discountPercent = 0
                        }
                    }
                }
            }
            .frame(width: 500)
        }
        .onAppear {
            if bill.discount > 0 {
                discountPercent = Int(bill.discount / bill.price * 100)
            }
        }
        .onDisappear {
            if !isCompleted {
                patient.updateBill(bill, for: appointment)
            }
        }
        .onChange(of: bill.price) { _, newValue in
            withAnimation {
                bill.discount = newValue * Double(discountPercent) / 100
            }
        }
    }
}

#Preview {
    PriceCalculationView(
        appointment: ExampleData.appointment,
        bill: .constant(Bill(services: [])),
        includeBalance: .constant(false),
        isCompleted: .constant(false)
    )
    .environmentObject(Coordinator())
}

// MARK: - Subviews

private extension PriceCalculationView {
    @ViewBuilder func discountButton(_ percent: Double) -> some View {
        let discount = bill.price * percent / 100
        Button("\(Int(percent))% (\(Int(discount.rounded())) ₽)") {
            bill.discount = discount.rounded()
            discountPercent = Int(percent)
        }
    }
}

// MARK: - Calculations

private extension PriceCalculationView {
    var patient: Patient {
        guard let patient = appointment.patient else { fatalError() }
        return patient
    }
}
