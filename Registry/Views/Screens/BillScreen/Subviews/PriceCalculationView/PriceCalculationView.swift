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
    @Binding var isCompleted: Bool

    // MARK: - State

    @State private var addDiscount: Bool = false
    @State private var payBill: Bool = false
    @State private var discountPercent: Int = 0

    // MARK: -

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                HStack {
                    Text(bill.discount > 0 ? "Промежуточный итог:" : "Итог:")
                        .font(.headline)
                    Spacer()
                    Text("\(Int(bill.price)) ₽")
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
                        patient.updatePaymentSubject(.bill(bill), forAppointmentID: appointment.id)
                        coordinator.present(
                            .billPayment(
                                appointment: appointment,
                                isPaid: $isCompleted
                            )
                        )
                    } label: {
                        Text("₽ \(Int(isCompleted ? bill.totalPrice + patient.balance : bill.totalPrice - patient.balance))")
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
                patient.updatePaymentSubject(.bill(bill), forAppointmentID: appointment.id)
            }
        }
        .onChange(of: bill.discount) { _, newValue in
            if newValue > 0 {
                withAnimation {
                    discountPercent = Int(bill.discount / bill.price * 100)
                }
            }
        }
    }
}

#Preview {
    PriceCalculationView(
        appointment: ExampleData.appointment,
        bill: .constant(Bill(services: [])),
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
