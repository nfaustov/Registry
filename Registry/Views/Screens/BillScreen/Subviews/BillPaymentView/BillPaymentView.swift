//
//  BillPaymentView.swift
//  Registry
//
//  Created by Николай Фаустов on 27.02.2024.
//

import SwiftUI
import SwiftData

struct BillPaymentView: View {
    // MARK: - Dependencies

    @Environment(\.user) private var user
    @Environment(\.modelContext) private var modelContext

    @Query private var doctors: [Doctor]

    private let appointment: PatientAppointment
    private let check: Check
    private let patient: Patient
    @Binding private var isPaid: Bool

    // MARK: - State

    @State private var paymentMethod: Payment.Method
    @State private var additionalPaymentMethod: Payment.Method? = nil
    @State private var todayReport: Report?
    @State private var lastReport: Report?

    // MARK: -

    init(appointment: PatientAppointment, isPaid: Binding<Bool>) {
        self.appointment = appointment
        _isPaid = isPaid

        guard let patient = appointment.patient,
              let check = appointment.check else { fatalError() }

        self.patient = patient
        self.check = check
        let paymentAmount = check.totalPrice - patient.balance
        _paymentMethod = State(initialValue: Payment.Method(.cash, value: paymentAmount))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Пациент") {
                    Text(patient.fullName)
                    LabeledContent("К оплате") {
                        Text("\(Int(check.totalPrice - patient.balance)) ₽")
                            .font(.headline)
                    }
                }

                CreatePaymentView(
                    account: patient,
                    paymentMethod: $paymentMethod,
                    additionalPaymentMethod: $additionalPaymentMethod
                )
                .paymentKind(.bill(totalPrice: check.totalPrice))
            }
            .sheetToolbar(title: "Оплата счёта", confirmationDisabled: undefinedPaymentValues) {
                if paymentBalance != 0 {
                    balancePayment()
                    patient.balance += paymentBalance
                }

                patient.mergedAppointments(forCheckID: check.id)
                    .forEach { $0.status = .completed }

                payment()
                check.makeChargesForServices()

                isPaid = true
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
    BillPaymentView(
        appointment: ExampleData.appointment,
        isPaid: .constant(false)
    )
}

// MARK: - Calculations

private extension BillPaymentView {
    var undefinedPaymentValues: Bool {
        guard let additionalPaymentMethod else { return paymentMethod.value == 0 }
        return additionalPaymentMethod.value == 0 || paymentMethod.value == 0
    }

    var paymentBalance: Double {
        paymentMethod.value + (additionalPaymentMethod?.value ?? 0) - check.totalPrice
    }

    func createReportWIthPayment(_ payment: Payment) {
        if let lastReport {
            let newReport = Report(date: .now, startingCash: lastReport.cashBalance, payments: [payment])
            modelContext.insert(newReport)
        } else {
            let firstReport = Report(date: .now, startingCash: 0, payments: [payment])
            modelContext.insert(firstReport)
        }
    }

    func balancePayment() {
        var balancePaymentMethod = paymentMethod
        balancePaymentMethod.value = paymentBalance
        let balancePayment = Payment(
            purpose: paymentBalance > 0 ? .toBalance(patient.initials) : .fromBalance(patient.initials),
            methods: [balancePaymentMethod],
            createdBy: user.asAnyUser
        )

        if let todayReport {
            todayReport.payment(balancePayment)
        } else {
            createReportWIthPayment(balancePayment)
        }
    }

    func payment() {
        var methods = [Payment.Method]()

        if let additionalPaymentMethod {
            methods.append(additionalPaymentMethod)
        } else {
            paymentMethod.value = check.totalPrice
        }

        methods.append(paymentMethod)

        let payment = Payment(purpose: .medicalServices(patient.initials), methods: methods, subject: check, createdBy: user.asAnyUser)

        if let todayReport {
            todayReport.payment(payment)
        } else {
            createReportWIthPayment(payment)
        }
    }
}
