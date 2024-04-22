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
                        DaySalaryView(doctor: doctor)
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
                Task {
                    let ledger = Ledger(modelContainer: modelContext.container)
                    await ledger.makeSalaryPayment(doctor: doctor, payoutType, methods: paymentMethods, createdBy: user)
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
    var paymentMethods: [Payment.Method] {
        paymentMethod.value = -abs(paymentMethod.value)
        var methods = [paymentMethod]

        if var additionalPaymentMethod {
            additionalPaymentMethod.value = -abs(additionalPaymentMethod.value)
            methods.append(additionalPaymentMethod)
        }

        return methods
    }

    var disabledAgentFee: Bool {
         payoutType == .agentFee && doctor.agentFee <= 0
    }

    var disabledBalancePayment: Bool {
        payoutType == .balance && doctor.balance <= 0
    }
}

// MARK: - PayoutType

enum PayoutType: Hashable, CaseIterable {
    case balance
    case agentFee

    func title(for employee: Employee) -> String {
        switch self {
        case .balance:
            if employee.doctorSalary.rate != nil {
                return "Заработная плата"
            } else {
                return "Выплата с баланса"
            }
        case .agentFee:
            return "Агентские"
        }
    }
}
