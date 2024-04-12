//
//  DoctorPayoutView.swift
//  Registry
//
//  Created by Николай Фаустов on 26.02.2024.
//

import SwiftUI
import SwiftData

struct DoctorPayoutView: View {
    // MARK: - Dependencies

    @Environment(\.user) private var user
    @Environment(\.modelContext) private var modelContext

    private let doctor: Doctor
    private let disabled: Bool

    // MARK: - State

    @State private var paymentMethod: Payment.Method
    @State private var additionalPaymentMethod: Payment.Method? = nil
    @State private var todayReport: Report?
    @State private var lastReport: Report?

    // MARK: -

    init(doctor: Doctor, disabled: Bool) {
        self.doctor = doctor
        self.disabled = disabled
        _paymentMethod = State(initialValue: Payment.Method(.cash, value: doctor.balance < 0 ? 0 : doctor.balance))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Врач") {
                    Text(doctor.fullName)
                    LabeledContent("Баланс") {
                        Text("\(Int(doctor.balance)) ₽")
                            .font(.headline)
                            .foregroundStyle(doctor.balance < 0 ? .red : .primary)
                    }
                }

                if let todayReport {
                    DaySalaryView(report: todayReport, doctor: doctor)
                }

                AgentFeeView(doctor: doctor)

                PaymentMethodView(
                    account: doctor,
                    paymentMethod: $paymentMethod,
                    additionalPaymentMethod: $additionalPaymentMethod
                )

                if additionalPaymentMethod == nil {
                    PaymentValueView(account: doctor, value: $paymentMethod.value)
                }
            }
            .sheetToolbar(
                title: "Выплата",
                confirmationDisabled: paymentMethod.value == 0 || doctor.balance <= 0 || disabled
            ) {
                doctorPayout()
                payment()
            }
            .task {
                var descriptor = FetchDescriptor<Report>(sortBy: [SortDescriptor(\.date, order: .reverse)])
                descriptor.fetchLimit = 1
                lastReport = try? modelContext.fetch(descriptor).first

                if let lastReport, Calendar.current.isDateInToday(lastReport.date) {
                    todayReport = lastReport
                }
            }
        }
    }
}

#Preview {
    DoctorPayoutView(doctor: ExampleData.doctor, disabled: false)
}

// MARK: - Calculations

private extension DoctorPayoutView {
    func createReportWithPayment(_ payment: Payment) {
        if let lastReport {
            let newReport = Report(date: .now, startingCash: lastReport.cashBalance, payments: [])
            modelContext.insert(newReport)
            newReport.payments.append(payment)
        } else {
            let firstReport = Report(date: .now, startingCash: 0, payments: [])
            modelContext.insert(firstReport)
            firstReport.payments.append(payment)
        }
    }

    func doctorPayout() {
        let totalPaymentValue = abs(paymentMethod.value) + abs(additionalPaymentMethod?.value ?? 0)
        doctor.charge(as: \.performer, amount: Double(-totalPaymentValue))
    }

    func payment() {
        paymentMethod.value = -abs(paymentMethod.value)
        var methods = [paymentMethod]

        additionalPaymentMethod?.value = -abs(additionalPaymentMethod?.value ?? 0)
        if let additionalPaymentMethod { methods.append(additionalPaymentMethod) }

        let purpose: Payment.Purpose = doctor.salary.rate == nil ? .fromBalance(doctor.initials) : .salary(doctor.initials)
        let payment = Payment(purpose: purpose, methods: methods, createdBy: user.asAnyUser)

        if let todayReport {
            todayReport.payments.append(payment)
        } else {
            createReportWithPayment(payment)
        }
    }
}
