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

    @Environment(\.user) private var user
    @Environment(\.modelContext) private var modelContext

    @Query private var doctors: [Doctor]

    private let appointment: PatientAppointment
    private let patient: Patient
    private let visit: Visit

    // MARK: - State

    @State private var editMode: Bool = false
    @State private var includeBalance: Bool
    @State private var paymentMethod: Payment.Method = Payment.Method(.cash, value: 0)
    @State private var balancePaymentMethod: Payment.Method = Payment.Method(.cash, value: 0)
    @State private var createdRefund: Refund = Refund(services: [])

    // MARK: -

    init(appointment: PatientAppointment) {
        self.appointment = appointment

        guard let visit = appointment.patient?.visit(forAppointmentID: appointment.id),
              let patient = appointment.patient else { fatalError() }

        self.patient = patient
        self.visit = visit
        _includeBalance = State(initialValue: patient.balance < 0)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(visit.bill?.services ?? []) { service in
                        HStack {
                            if editMode { toggle(service: service).padding(.trailing) }

                            Group {
                                Text(service.pricelistItem.title)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("\(Int(service.pricelistItem.price))")
                                    .frame(width: 60)
                            }
                            .foregroundStyle(serviceItemForegroudColor(service))
                        }
                    }
                } header: {
                    HStack {
                        Text(editMode ? "Выберите услуги" : "Услуги")
                    }
                }

                Section {
                    Text("Цена: \(Int(visit.bill?.price ?? 0)) ₽")
                        .font(.subheadline)

                    if let discount = visit.bill?.discount, discount != 0 {
                        Text("Скидка: \(Int(discount)) ₽")
                            .font(.subheadline)
                    }

                    Text("Оплачено: \(Int(visit.bill?.totalPrice ?? 0)) ₽")
                        .font(.headline)
                } header: {
                    Text("Итог")
                }

                if let refund = visit.refund {
                    Text("Возврат: \(Int(refund.totalAmount(discountRate: visit.bill?.discountRate ?? 0))) ₽")
                        .font(.headline)
                        .foregroundColor(.red)
                } else {
                    refundSection

                    if !createdRefund.services.isEmpty {
                        balancePaymentSection
                    }
                }
                
            }
            .sheetToolbar(
                title: "Счет",
                subtitle: appointment.patient?.fullName,
                confirmationDisabled: visit.refund != nil || (visit.refund == nil && createdRefund.services.isEmpty) || editMode,
                onConfirm: visit.refund != nil ? nil : {
                    createPayment()
                    SalaryCharger.charge(for: .refund(createdRefund), doctors: doctors)
                    patient.updatePaymentSubject(.refund(createdRefund), forAppointmentID: appointment.id)
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
            if !createdRefund.services.isEmpty {
                Text("Возврат: \(Int(createdRefund.totalAmount(discountRate: visit.bill?.discountRate ?? 0))) ₽")
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
                Text(editMode ? "Готово" : createdRefund.services.isEmpty ? "Оформить возврат" : "Изменить")
                    .foregroundColor(editMode ? .blue : createdRefund.services.isEmpty ? .red : .blue)
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
                get: { createdRefund.services.contains(service) },
                set: { value in
                    if value {
                        createdRefund.services.append(service)
                    } else {
                        createdRefund.services.removeAll(where: { $0.id == service.id })
                    }
                }
            )
        )
        .toggleStyle(.minusBox)
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
        if let refund = visit.refund {
            return refund.services.contains(service) ? .red.opacity(0.5) : .primary
        } else {
            return createdRefund.services.contains(service) ? .red : .primary
        }
    }

    func createPayment() {
        paymentMethod.value = createdRefund.totalAmount(discountRate: visit.bill?.discountRate ?? 0)
        let payment = Payment(purpose: .refund(patient.initials), methods: [paymentMethod], subject: .refund(createdRefund), createdBy: user.asAnyUser)
        todayReport?.payments.append(payment)
    }

    func createBalancePayment() {
        balancePaymentMethod.value = -patient.balance
        let purpose: Payment.Purpose = patient.balance > 0 ? .fromBalance(patient.initials) : .toBalance(patient.initials)
        let payment = Payment(purpose: purpose, methods: [balancePaymentMethod], createdBy: user.asAnyUser)
        todayReport?.payments.append(payment)
        patient.updateBalance(increment: -patient.balance)
    }
}
