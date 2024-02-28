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

    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Report.date, order: .forward) private var reports: [Report]

    private let doctor: Doctor

    // MARK: - State

    @State private var paymentMethod: Payment.Method
    @State private var additionalPaymentMethod: Payment.Method? = nil
    @State private var paymentBalance: Int = 0

    // MARK: -

    init(doctor: Doctor) {
        self.doctor = doctor
        _paymentMethod = State(initialValue: Payment.Method(.cash, value: doctor.balance))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Врач") {
                    Text(doctor.fullName)

                    HStack {
                        Text("Баланс")
                        Spacer()
                        Text("\(Int(doctor.balance)) ₽")
                            .font(.headline)
                    }
                }

                if salary > 0 {
                    Section {
                        DisclosureGroup {
                            List(servicesByDoctor) { service in
                                HStack {
                                    Text(service.pricelistItem.title)
                                    Spacer()
                                    Text("\(Int(service.pricelistItem.price * rate)) ₽")
                                        .frame(width: 60)
                                }
                                .font(.subheadline)
                            }
                        } label: {
                            HStack {
                                Text("Заработная плата")
                                Spacer()
                                Text("\(Int(salary)) ₽")
                                    .font(.headline)
                            }
                        }
                    }
                }

                Section {
                    if doctor.agentFee > 0 {
                        DisclosureGroup {
                            List(servicesByAgent) { service in
                                HStack {
                                    Text(service.pricelistItem.title)
                                    Spacer()
                                    Text("\(Int(service.pricelistItem.price * 0.1)) ₽")
                                        .frame(width: 60)
                                }
                                .font(.subheadline)
                            }
                        } label: { agentFeeTitle }
                    } else {
                        agentFeeTitle
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    if let additionalPaymentMethod {
                        HStack {
                            Text(paymentMethod.type.rawValue)
                            Spacer()
                            textField(type: paymentMethod.type)
                                .onChange(of: paymentMethod.value) { _, newValue in
                                    self.additionalPaymentMethod?.value = doctor.balance - newValue
                                }
                        }

                        HStack {
                            Text(additionalPaymentMethod.type.rawValue)
                            Spacer()
                            textField(type: additionalPaymentMethod.type)
                                .onChange(of: self.additionalPaymentMethod?.value ?? 0) { _, newValue in
                                    paymentMethod.value = doctor.balance - newValue
                                }
                        }
                    } else {
                        Picker(paymentMethod.type.rawValue, selection: $paymentMethod.type) {
                            ForEach(PaymentType.allCases, id: \.self) { type in
                                if type != .bank {
                                    Text(type.rawValue)
                                }
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
                                    additionalPaymentMethod = nil
                                    paymentMethod.value = doctor.balance
                                }
                            } label: {
                                Image(systemName: "arrow.uturn.left")
                            }
                        }
                    }
                }
                
                Button("Добавить способ оплаты") {
                    withAnimation {
                        switch paymentMethod.type {
                        case .cash: additionalPaymentMethod = Payment.Method(.card, value: 0)
                        case .card: additionalPaymentMethod = Payment.Method(.cash, value: 0)
                        default: ()
                        }
                        paymentBalance = 0
                    }
                }
                .disabled(additionalPaymentMethod != nil)

                if additionalPaymentMethod == nil {
                    Section {
                        HStack {
                            TextField("Сумма выплаты", value: $paymentMethod.value, format: .number)
                                .onChange(of: paymentMethod.value) {
                                    paymentBalance = Int(doctor.balance - paymentMethod.value)
                                }
                            Spacer()
                            Image(systemName: "pencil")
                                .foregroundColor(.secondary)
                        }
                    } header: {
                        Text("Сумма вылаты")
                    } footer: {
                        HStack {
                            Text("Остаток на балансе: \(paymentBalance) ₽")
                                .foregroundColor(paymentBalance < 0 ? .red : .secondary)
                        }
                    }
                }
            }
            .sheetToolbar(
                title: "Выплата",
                confirmationDisabled: paymentMethod.value == 0 || doctor.balance == 0
            ) {
                doctorPayout()
                payment()
            }
        }
    }
}

#Preview {
    DoctorPayoutView(doctor: ExampleData.doctor)
}

// MARK: - Subviews

private extension DoctorPayoutView {
    func textField(type: PaymentType) -> some View {
        ZStack(alignment: .trailing) {
            Color.gray
                .opacity(0.1)
                .cornerRadius(8)
            TextField(
                type.rawValue,
                value: type == paymentMethod.type ? $paymentMethod.value : Binding(get: { additionalPaymentMethod!.value }, set: { additionalPaymentMethod?.value = $0 }),
                format: .number
            )
            .padding(.horizontal)
        }
        .frame(width: 120)
    }

    var agentFeeTitle: some View {
        HStack {
            Text("Агентские")
            Spacer()
            Text("\(Int(doctor.agentFee)) ₽")
                .font(.headline)
        }
    }
}

// MARK: - Calculations

private extension DoctorPayoutView {
    var salary: Double {
        switch doctor.salary {
        case .pieceRate(let rate):
            return servicesByDoctor
                .reduce(0.0) { $0 + $1.pricelistItem.price * rate }
        default: return 0
        }
    }

    var rate: Double {
        switch doctor.salary {
        case .pieceRate(let rate): return rate
        default: return 0
        }
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

    var currentMonthReports: [Report] {
        let components = Calendar.current.dateComponents([.year, .month], from: .now)
        let date = Calendar.current.date(from: components)!
        let today = Date.now

        return reports.filter { $0.date > date && $0.date < today }
    }

    var servicesByDoctor: [RenderedService] {
        doctor.renderedServices(from: todayReport.payments, role: \.performer)
    }

    var servicesByAgent: [RenderedService] {
        doctor.renderedServices(
            from: currentMonthReports.flatMap { $0.payments },
            role: \.agent
        )
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

        let payment = Payment(purpose: .salary(doctor.initials), methods: methods)
        todayReport.payments.append(payment)
    }
}
