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
    @State private var payoutType: PayoutType = .balance

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

                Section {
                    if doctor.agentFee > 0 {
                        Picker("Выплата", selection: $payoutType) {
                            ForEach(PayoutType.allCases, id: \.self) { type in
                                Text(type.title(for: doctor))
                            }
                        }
                    } else {
                        Text(payoutType.title(for: doctor))
                            .foregroundStyle(.secondary)
                    }

                    if payoutType == .balance {
                        if let todayReport {
                            DaySalaryView(report: todayReport, employee: doctor)
                        }
                    } else if payoutType == .agentFee {
                        AgentFeeView(doctor: doctor)
                    }
                }

                CreatePaymentView(
                    account: doctor,
                    paymentMethod: $paymentMethod,
                    additionalPaymentMethod: $additionalPaymentMethod
                )
                .paymentKind(.balance)
            }
            .sheetToolbar(
                title: "Выплата",
                confirmationDisabled: paymentMethod.value == 0 ||
                disabled || disabledAgentFee ||
                disabledBalancePayment
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
        switch payoutType {
        case .balance: 
            doctor.charge(as: \.performer, amount: -totalPaymentValue)
        case .agentFee:
            doctor.agentFeePayment(value: totalPaymentValue)
        }
    }

    func payment() {
        paymentMethod.value = -abs(paymentMethod.value)
        var methods = [paymentMethod]

        additionalPaymentMethod?.value = -abs(additionalPaymentMethod?.value ?? 0)
        if let additionalPaymentMethod { methods.append(additionalPaymentMethod) }

        let payment = Payment(purpose: paymentPurpose(), methods: methods, createdBy: user.asAnyUser)

        if let todayReport {
            todayReport.payments.append(payment)
        } else {
            createReportWithPayment(payment)
        }
    }

    func paymentPurpose() -> Payment.Purpose {
        switch payoutType {
        case .balance:
            return doctor.salary.rate == nil ? .fromBalance(doctor.initials) : .salary(doctor.initials)
        case .agentFee:
            return .agentFee(doctor.initials)
        }
    }

    var disabledAgentFee: Bool {
         payoutType == .agentFee && doctor.agentFee <= 0
    }

    var disabledBalancePayment: Bool {
        payoutType == .balance && doctor.balance <= 0
    }
}

// MARK: - PayoutType

private extension DoctorPayoutView {
    enum PayoutType: Hashable, CaseIterable {
        case balance
        case agentFee

        func title(for employee: Employee) -> String {
            switch self {
            case .balance:
                if employee.salary.rate != nil {
                    return "Заработная плата"
                } else {
                    return "Выплата с баланса"
                }
            case .agentFee:
                return "Агентские"
            }
        }
    }
}
