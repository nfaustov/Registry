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

    @Environment(\.modelContext) private var modelContext

    @Query private var doctors: [Doctor]
    @Query(sort: \Report.date, order: .forward) private var reports: [Report]

    private let appointment: PatientAppointment
    private let includedPatientBalance: Double
    private let bill: Bill
    @Binding private var isPaid: Bool

    // MARK: - State

    @State private var paymentMethod: Payment.Method
    @State private var additionalPaymentMethod: Payment.Method? = nil
    @State private var paymentBalance: Int = 0
    @State private var addToBalance: Bool = false

    // MARK: -

    init(appointment: PatientAppointment, includedPatientBalance: Double, bill: Bill, isPaid: Binding<Bool>) {
        self.appointment = appointment
        self.includedPatientBalance = includedPatientBalance
        self.bill = bill
        _isPaid = isPaid
        _paymentMethod = State(initialValue: Payment.Method(.cash, value: bill.totalPrice - includedPatientBalance))
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
                    Text("\(Int(bill.totalPrice - includedPatientBalance)) ₽")
                        .fontWeight(.medium)
                } header: {
                    Text("К оплате")
                }

                Section {
                    if let additionalPaymentMethod {
                        HStack {
                            Text(paymentMethod.type.rawValue)
                            Spacer()
                            textField(type: paymentMethod.type)
                                .onChange(of: paymentMethod.value) { _, newValue in
                                    self.additionalPaymentMethod?.value = bill.totalPrice - newValue - includedPatientBalance
                                }
                        }

                        HStack {
                            Text(additionalPaymentMethod.type.rawValue)
                            Spacer()
                            textField(type: additionalPaymentMethod.type)
                                .onChange(of: self.additionalPaymentMethod?.value ?? 0) { _, newValue in
                                    paymentMethod.value = bill.totalPrice - newValue - includedPatientBalance
                                }
                        }
                    } else {
                        Picker(paymentMethod.type.rawValue, selection: $paymentMethod.type) {
                            ForEach(PaymentType.allCases, id: \.self) { type in
                                Text(type.rawValue)
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("Способ оплаты")

                        if additionalPaymentMethod != nil {
                            Spacer()
                            Button {
                                withAnimation {
                                    self.additionalPaymentMethod = nil
                                    paymentMethod.value = bill.totalPrice - includedPatientBalance
                                }
                            } label: {
                                Image(systemName: "arrow.uturn.left")
                            }
                        }
                    }
                }
                
                Menu("Добавить способ оплаты") {
                    ForEach(PaymentType.allCases, id: \.self) { type in
                        if type != paymentMethod.type {
                            Button(type.rawValue) {
                                withAnimation {
                                    additionalPaymentMethod = Payment.Method(type, value: 0)
                                    paymentBalance = 0
                                }
                            }
                        }
                    }
                }
                .disabled(additionalPaymentMethod != nil)
                
                if additionalPaymentMethod == nil {
                    Section {
                        HStack {
                            TextField("Сумма оплаты", value: $paymentMethod.value, format: .number)
                                .onChange(of: paymentMethod.value) {
                                    paymentBalance = Int(paymentMethod.value - bill.totalPrice)
                                }
                            Spacer()
                            Image(systemName: "pencil")
                                .foregroundColor(.secondary)
                        }
                    } header: {
                        Text("Сумма оплаты")
                    } footer: {
                        if paymentBalance != 0 {
                            HStack {
                                if paymentBalance < 0 {
                                    Text("Долг \(-paymentBalance) ₽.")
                                        .foregroundColor(.red)
                                    Text("Баланс пациента составит \(paymentBalance + Int(patient.balance)) ₽")
                                } else {
                                    Text(addToBalance ?
                                         "Баланс пациента увеличится на \(paymentBalance) ₽ и составит \(paymentBalance + Int(patient.balance)) ₽" :
                                         "Сдача: \(paymentBalance) ₽"
                                    )

                                    Spacer()

                                    Button(addToBalance ? "Выдать сдачу" : "Записать на счёт") {
                                        addToBalance.toggle()
                                    }
                                    .font(.footnote)
                                }
                            }
                        }
                    }
                }
            }
            .sheetToolbar(title: "Оплата счёта", confirmationDisabled: paymentMethod.value == 0) {
                isPaid = true
                patient.updateBill(bill, for: appointment)

                let balance = Double(paymentBalance) - includedPatientBalance
                completeAppointment(paymentBalance: balance)

                if (balance) < 0 || addToBalance {
                    balancePayment()
                }

                payment()
                doctorSalary(bill: bill)
            }
        }
    }
}

#Preview {
    BillPaymentView(
        appointment: ExampleData.appointment,
        includedPatientBalance: 0,
        bill: Bill(services: []),
        isPaid: .constant(false)
    )
}

// MARK: - Subviews

private extension BillPaymentView {
    func textField(type: PaymentType) -> some View {
        ZStack(alignment: .trailing) {
            Color.gray
                .opacity(0.1)
                .cornerRadius(8)
            TextField(
                type.rawValue,
                value: type == paymentMethod.type ? $paymentMethod.value : Binding(get: { additionalPaymentMethod!.value }, set: { additionalPaymentMethod?.value = $0 }) ,
                format: .number
            )
            .padding(.horizontal)
        }
        .frame(width: 120)
    }
}

// MARK: - Calculations

private extension BillPaymentView {
    var patient: Patient {
        guard let patient = appointment.patient else { fatalError() }
        return patient
    }

    var todayReport: Report {
        if let report = reports.first {
            if Calendar.current.isDateInToday(report.date) {
                return report
            } else {
                let newReport = Report(date: .now, startingCash: report.cashBalance, payments: [])
                modelContext.insert(newReport)

                return newReport
            }
        } else {
            let firstReport = Report(date: .now, startingCash: 0, payments: [])
            modelContext.insert(firstReport)

            return firstReport
        }
    }

    func doctorSalary(bill: Bill, refund: Bool = false) {
        for service in bill.services {
            if let performer = service.performer {
                var salary = Double.zero

                switch performer.salary {
                case .pieceRate(let rate):
                    salary = service.pricelistItem.price * rate
                case .perService(let amount):
                    salary = Double(amount)
                default: ()
                }

                guard let doctor = doctors.first(where: { $0.id == performer.id }) else { return }

                doctor.charge(as: \.performer, amount: refund ? -salary : salary)
            }

            if let agent = service.agent {
                let agentFee = service.pricelistItem.price  * 0.1

                guard let doctor = doctors.first(where: { $0.id == agent.id }) else { return }

                doctor.charge(as: \.agent, amount: refund ? -agentFee : agentFee)
            }
        }
    }

    func completeAppointment(paymentBalance: Double) {
        if paymentBalance != 0 {
            patient.balance += paymentBalance
        }
        appointment.status = .completed
    }

    func balancePayment() {
        var balancePaymentMethod = paymentMethod
        balancePaymentMethod.value = Double(paymentBalance) - includedPatientBalance
        let balancePayment = Payment(
            purpose: balancePaymentMethod.value > 0 ? .toBalance(patient.initials) : .fromBalance(patient.initials),
            methods: [balancePaymentMethod]
        )
        todayReport.payments.append(balancePayment)
    }

    func payment() {
        var methods = [Payment.Method]()

        if let additionalPaymentMethod {
            methods.append(additionalPaymentMethod)
        } else {
            paymentMethod.value = bill.totalPrice
        }

        methods.append(paymentMethod)

        let payment = Payment(purpose: .medicalServices(patient.initials), methods: methods, bill: bill)
        todayReport.payments.append(payment)
    }
}
