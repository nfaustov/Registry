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

    @Query(sort: \Report.date, order: .reverse) private var reports: [Report]

    private let doctor: Doctor

    // MARK: - State

    @State private var paymentMethod: Payment.Method
    @State private var additionalPaymentMethod: Payment.Method? = nil

    // MARK: -

    init(doctor: Doctor) {
        self.doctor = doctor
        _paymentMethod = State(initialValue: Payment.Method(.cash, value: doctor.balance < 0 ? 0 : doctor.balance))
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
                            .foregroundStyle(doctor.balance < 0 ? .red : .primary)
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
                                Text("Заработано сегодня")
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
                            List(Array(servicesByAgent.keys), id: \.self) { date in
                                VStack(alignment: .leading) {
                                    DateText(date, format: .date)
                                        .fontWeight(.medium)
                                    ForEach(servicesByAgent[date] ?? []) { service in
                                        Divider()
                                        HStack {
                                            Text(service.pricelistItem.title)
                                            Spacer()
                                            Text("\(Int(service.pricelistItem.price * 0.1)) ₽")
                                                .frame(width: 60)
                                        }
                                    }
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
                                    self.additionalPaymentMethod?.value = 0
                                    self.additionalPaymentMethod?.value = Double(paymentBalance) - newValue
                                }
                        }

                        HStack {
                            Text(additionalPaymentMethod.type.rawValue)
                            Spacer()
                            textField(type: additionalPaymentMethod.type)
                                .onChange(of: self.additionalPaymentMethod?.value ?? 0) { _, newValue in
                                    paymentMethod.value = 0
                                    paymentMethod.value = Double(paymentBalance) - newValue
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
                        paymentMethod.value = 0
                        paymentMethod.value = Double(paymentBalance)
                    }
                }
                .disabled(additionalPaymentMethod != nil)

                if additionalPaymentMethod == nil {
                    Section {
                        HStack {
                            TextField("Сумма выплаты", value: $paymentMethod.value, format: .number)
                                .onChange(of: paymentMethod.value) { _, newValue in
                                    if newValue < 0 {
                                        paymentMethod.value = -newValue
                                    }
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
            Text("Агентские за этот месяц")
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

    var paymentBalance: Int {
        Int(doctor.balance - paymentMethod.value - (additionalPaymentMethod?.value ?? 0))
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

    var servicesByDoctor: [RenderedService] {
        doctor.renderedServices(from: todayReport.payments, role: \.performer)
    }

    var servicesByAgent: [Date: [RenderedService]] {
        let components = Calendar.current.dateComponents([.year, .month], from: .now)
        let firstDayOfCurrentMonth = Calendar.current.date(from: components)!
        let today = Date.now

        let reports = reports
            .filter { $0.date > firstDayOfCurrentMonth && $0.date < today }
            .sorted(by: { $0.date < $1.date })

        var dict = [Date: [RenderedService]]()

        for report in reports {
            let services = doctor.renderedServices(from: report.payments, role: \.agent)

            if !services.isEmpty {
                dict[report.date] = services
            }
        }

        return dict
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
