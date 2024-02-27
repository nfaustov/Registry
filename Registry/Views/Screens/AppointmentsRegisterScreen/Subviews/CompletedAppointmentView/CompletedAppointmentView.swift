//
//  CompletedAppointmentView.swift
//  Registry
//
//  Created by Николай Фаустов on 27.02.2024.
//

import SwiftUI
import SwiftData

struct CompletedAppointmentView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    @Query private var doctors: [Doctor]

    private let appointment: PatientAppointment
    private let bill: Bill
    private let patient: Patient

    // MARK: - State

    @State private var editMode: Bool = false
    @State private var includeBalance: Bool
    @State private var paymentMethod: Payment.Method = Payment.Method(.cash, value: 0)
    @State private var balancePaymentMethod: Payment.Method = Payment.Method(.cash, value: 0)
    @State private var createdRefundBill: Bill = Bill(services: [])
    @State private var refundBill: Bill?

    // MARK: -

    init(appointment: PatientAppointment) {
        self.appointment = appointment

        guard let visits = appointment.patient?.visits,
              let bill = visits.first(
                where: { $0.visitDate == appointment.scheduledTime && !$0.isRefund }
              )?.bill,
              let patient = appointment.patient else { fatalError() }

        self.bill = bill
        self.patient = patient
        _refundBill = State(
            initialValue: visits.first(where: { $0.visitDate == appointment.scheduledTime && $0.isRefund })?.bill
        )
        _includeBalance = State(initialValue: patient.balance < 0)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(bill.services) { service in
                        HStack {
                            if editMode { toggle(service: service).padding(.trailing) }

                            Group {
                                Text(service.pricelistItem.title)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("\(Int(service.pricelistItem.price))")
                                    .frame(width: 60)
                            }
                            .foregroundColor(serviceItemForegroudColor(service))
                        }
                    }
                } header: {
                    HStack {
                        Text(editMode ? "Выберите услуги" : "Услуги")
                    }
                }

                Section {
                    Text("Цена: \(Int(bill.price)) ₽")
                        .font(.subheadline)

                    if bill.discount != 0 {
                        Text("Скидка: \(Int(bill.discount)) ₽")
                            .font(.subheadline)
                    }

                    Text("Оплачено: \(Int(bill.totalPrice)) ₽")
                        .font(.headline)
                } header: {
                    Text("Итог")
                }

                if let refundBill {
                    Text("Возврат: \(Int(refundBill.totalPrice)) ₽")
                        .font(.headline)
                        .foregroundColor(.red)
                } else {
                    refundSection

                    if !createdRefundBill.services.isEmpty {
                        balancePaymentSection
                    }
                }
                
            }
            .sheetToolbar(
                title: "Счет",
                subtitle: appointment.patient?.fullName,
                confirmationDisabled: refundBill != nil || (refundBill == nil && createdRefundBill.services.isEmpty) || editMode,
                onConfirm: refundBill != nil ? nil : {
                    createPayment()
                    doctorSalary(bill: createdRefundBill, refund: true)
                    createVisit()
                    if includeBalance {
                        createBalancePayment()
                    }
                }
            )
        }
    }
}

#Preview {
    CompletedAppointmentView(appointment: ExampleData.appointment)
}

// MARK: - Subviews

private extension CompletedAppointmentView {
    var refundSection: some View {
        Section {
            if !createdRefundBill.services.isEmpty {
                Text("Возврат: \(Int(createdRefundBill.totalPrice)) ₽")
                    .font(.headline)
                    .foregroundColor(.red)

                Picker("Способ оплаты", selection: $paymentMethod.type) {
                    ForEach(PaymentType.allCases, id: \.self) { type in
                        Text(type.rawValue)
                    }
                }
            }

            Button {
                withAnimation(.easeOut(duration: 0.15)) {
                    editMode.toggle()
                }
            } label: {
                Text(editMode ? "Готово" : createdRefundBill.services.isEmpty ? "Оформить возврат" : "Изменить")
                    .foregroundColor(editMode ? .blue : createdRefundBill.services.isEmpty ? .red : .blue)
                    .fontWeight(editMode ? .medium : .regular)
            }
        }
    }

    var balancePaymentSection: some View {
        Section {
            if patient.balance != 0 {
                HStack {
                    if patient.balance > 0 {
                        Text("Мы должны пациенту: \(Int(patient.balance)) ₽")
                    } else if patient.balance < 0 {
                        Text("Пациент должен нам: \(Int(-patient.balance)) ₽")
                    }

                    Spacer()

                    Toggle("", isOn: $includeBalance.animation())
                        .disabled(patient.balance < 0)
                }
                .font(.subheadline)

                if includeBalance {
                    Picker("Способ оплаты по балансу", selection: $balancePaymentMethod.type) {
                        ForEach(PaymentType.allCases, id: \.self) { type in
                            Text(type.rawValue)
                        }
                    }
                }
            }
        }
    }

    func toggle(service: RenderedService) -> some View {
        Toggle(
            service.id.uuidString,
            isOn: Binding(
                get: { createdRefundBill.services.contains(service) },
                set: { value in
                    if value {
                        createdRefundBill.services.append(service)
                        createdRefundBill.discount = createdRefundBill.price * bill.discountRate
                    } else {
                        createdRefundBill.services.removeAll(where: { $0.id == service.id })
                    }
                }
            )
        )
        .toggleStyle(iOSCheckBoxToggleStyle())
    }
}

// MARK: - Calculations

private extension CompletedAppointmentView {
    var todayReport: Report? {
        let startOfToday = Calendar.current.startOfDay(for: .now)
        let startOfTommorow = Calendar.current.startOfDay(for: .now.addingTimeInterval(86_400))
        let predicate = #Predicate<Report> {
            $0.date > startOfToday && $0.date < startOfTommorow
        }
        let descriptor = FetchDescriptor(predicate: predicate)

        return try? modelContext.fetch(descriptor).first
    }

    func serviceItemForegroudColor(_ service: RenderedService) -> Color {
        if let refundBill {
            return refundBill.services.contains(service) ? .red.opacity(0.5) : .primary
        } else {
            return createdRefundBill.services.contains(service) ? .red : .primary
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

    func createPayment() {
        paymentMethod.value = -createdRefundBill.totalPrice
        let payment = Payment(purpose: .refund(patient.initials), methods: [paymentMethod], bill: createdRefundBill)
        todayReport?.payments.append(payment)
    }

    func createVisit() {
        let visit = Visit(
            visitDate: appointment.scheduledTime,
            bill: createdRefundBill,
            isRefund: true
        )
        patient.visits.append(visit)
    }

    func createBalancePayment() {
        balancePaymentMethod.value = -patient.balance
        let purpose: Payment.Purpose = patient.balance > 0 ? .fromBalance(patient.initials) : .toBalance(patient.initials)
        let payment = Payment(purpose: purpose, methods: [balancePaymentMethod])
        todayReport?.payments.append(payment)
        patient.balance = 0
    }
}
