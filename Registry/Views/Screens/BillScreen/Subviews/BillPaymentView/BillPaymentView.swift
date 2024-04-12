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
    @Query(sort: \Report.date, order: .reverse) private var reports: [Report]

    private let appointment: PatientAppointment
    private let bill: Bill
    private let patient: Patient
    @Binding private var isPaid: Bool

    // MARK: - State

    @State private var paymentMethod: Payment.Method
    @State private var additionalPaymentMethod: Payment.Method? = nil
    @State private var addToBalance: Bool = false

    // MARK: -

    init(appointment: PatientAppointment, isPaid: Binding<Bool>) {
        self.appointment = appointment
        _isPaid = isPaid

        guard let patient = appointment.patient,
              let visit = patient.visit(forAppointmentID: appointment.id),
              let bill = visit.bill else { fatalError() }

        self.patient = patient
        self.bill = bill
        let paymentAmount = bill.totalPrice - patient.balance
        _paymentMethod = State(initialValue: Payment.Method(.cash, value: paymentAmount))
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(patient.fullName)
                } header: {
                    Text("Пациент")
                }

                Section {
                    Text("\(Int(bill.totalPrice - patient.balance)) ₽")
                        .fontWeight(.medium)
                } header: {
                    Text("К оплате")
                }

                CreatePaymentView(
                    account: patient,
                    paymentMethod: $paymentMethod,
                    additionalPaymentMethod: $additionalPaymentMethod,
                    paymentFooter: { paymentBalance in
                        if paymentBalance < 0 {
                            Text("Долг \(-paymentBalance) ₽.")
                                .foregroundColor(.red)
                        } else {
                            HStack {
                                Text(addToBalance ?
                                     "Баланс пациента составит \(paymentBalance) ₽." :
                                     "Сдача: \(paymentBalance) ₽."
                                )

                                Spacer()

                                Button(addToBalance ? "Выдать сдачу" : "Записать на счёт") {
                                    addToBalance.toggle()
                                }
                                .font(.footnote)
                            }
                        }
                    }
                )
                .paymentKind(.bill(totalPrice: bill.totalPrice))
            }
            .sheetToolbar(title: "Оплата счёта", confirmationDisabled: undefinedPaymentValues) {
                if paymentBalance < 0 || addToBalance {
                    balancePayment(value: paymentBalance)
                    patient.updateBalance(increment: paymentBalance)
                } else if patient.balance != 0 {
                    balancePayment(value: -patient.balance)
                    patient.updateBalance(increment: -patient.balance)
                }

                patient.mergedAppointments(forAppointmentID: appointment.id)
                    .forEach { $0.status = .completed }

                payment()
                SalaryCharger.charge(for: .bill(bill), doctors: doctors)

                isPaid = true
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
        patient.balance + paymentMethod.value + (additionalPaymentMethod?.value ?? 0) - bill.totalPrice
    }

    var todayReport: Report? {
        if let report = reports.first, Calendar.current.isDateInToday(report.date) {
            return report
        } else {
            return nil
        }
    }

    func createReportWIthPayment(_ payment: Payment) {
        if let report = reports.first {
            let newReport = Report(date: .now, startingCash: report.cashBalance, payments: [])
            modelContext.insert(newReport)
            newReport.payments.append(payment)
        } else {
            let firstReport = Report(date: .now, startingCash: 0, payments: [])
            modelContext.insert(firstReport)
            firstReport.payments.append(payment)
        }
    }

    func balancePayment(value: Double) {
        var balancePaymentMethod = paymentMethod
        balancePaymentMethod.value = value
        let balancePayment = Payment(
            purpose: value > 0 ? .toBalance(patient.initials) : .fromBalance(patient.initials),
            methods: [balancePaymentMethod],
            createdBy: user.asAnyUser
        )

        if let todayReport {
            todayReport.payments.append(balancePayment)
        } else {
            createReportWIthPayment(balancePayment)
        }
    }

    func payment() {
        var methods = [Payment.Method]()

        if let additionalPaymentMethod {
            methods.append(additionalPaymentMethod)
        } else {
            paymentMethod.value = bill.totalPrice
        }

        methods.append(paymentMethod)

        let payment = Payment(purpose: .medicalServices(patient.initials), methods: methods, subject: .bill(bill), createdBy: user.asAnyUser)
        if let todayReport {
            todayReport.payments.append(payment)
        } else {
            createReportWIthPayment(payment)
        }
        
    }
}
