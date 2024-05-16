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
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var coordinator: Coordinator

    private let appointment: PatientAppointment
    private let patient: Patient

    // MARK: - State

    @State private var editMode: Bool = false
    @State private var includeBalance: Bool
    @State private var paymentMethod: Payment.Method = Payment.Method(.cash, value: 0)
    @State private var balancePaymentMethod: Payment.Method = Payment.Method(.cash, value: 0)
    @State private var createdRefund: Refund = Refund()

    // MARK: -

    init(appointment: PatientAppointment) {
        self.appointment = appointment

        guard let patient = appointment.patient else { fatalError() }

        self.patient = patient
        _includeBalance = State(initialValue: patient.balance < 0)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(appointment.check?.services ?? []) { service in
                        HStack {
                            if editMode { toggle(service: service).padding(.trailing) }

                            LabeledCurrency(service.pricelistItem.title, value: service.pricelistItem.price, unit: false)
                                .foregroundStyle(serviceItemForegroudColor(service))
                        }
                    }
                } header: {
                    HStack {
                        Text(editMode ? "Выберите услуги" : "Услуги")
                    }
                }

                Section("Итог") {
                    LabeledCurrency("Цена", value: appointment.check?.price ?? 0)

                    if let discount = appointment.check?.discount, discount != 0 {
                        LabeledCurrency("Скидка", value: discount)
                    }
                }

                Section("Оплата") {
                    if let payment = appointment.check?.payment {
                        ForEach(payment.methods, id: \.self) { method in
                            LabeledCurrency(method.type.rawValue, value: method.value)
                        }
                        if payment.methods.count > 1 {
                            LabeledCurrency("Всего", value: payment.totalAmount)
                                .font(.headline)
                        }
                    }
                }

                if let refund = appointment.check?.refund {
                    LabeledCurrency("Возврат", value: refund.totalAmount)
                        .font(.headline)
                        .foregroundStyle(.red)
                } else {
                    refundSection

                    if !createdRefund.services.isEmpty {
                        balancePaymentSection
                    }
                }

                if Calendar.current.isDateInToday(appointment.scheduledTime), appointment.check?.refund == nil {
                    Section {
                        Button("Редактировать роли") {
                            dismiss()
                            coordinator.push(.bill(for: appointment, purpose: .editRoles))
                        }
                    }
                }
            }
            .sheetToolbar(
                "Счет",
                subtitle: appointment.patient?.fullName,
                disabled: appointment.check?.refund != nil || (appointment.check?.refund == nil && createdRefund.services.isEmpty) || editMode,
                task: appointment.check?.refund != nil ? nil : {
                    if let check = appointment.check {
                        check.makeRefund(createdRefund)
                        let ledger = Ledger(modelContainer: modelContext.container)
                        await ledger.makeRefundPayment(refund: createdRefund, method: paymentMethod, includeBalance: includeBalance, createdBy: user)
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
                let refundTotalAmount = (appointment.check?.discountRate ?? 0) * createdRefund.price - createdRefund.price
                LabeledCurrency("Возврат", value: refundTotalAmount)
                    .font(.headline)
                    .foregroundStyle(.red)

                if includeBalance {
                    LabeledCurrency("Выплата", value: refundTotalAmount - patient.balance)
                        .font(.headline)
                }

                Picker("Способ возврата", selection: $paymentMethod.type) {
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
                LabeledCurrency("Баланс пациента", value: patient.balance)
                Toggle("Включить в платеж", isOn: $includeBalance.animation())
                    .disabled(patient.balance < 0)
            }
        }
    }

    func toggle(service: MedicalService) -> some View {
        Toggle(
            "",
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

    func serviceItemForegroudColor(_ service: MedicalService) -> Color {
        if let refund = appointment.check?.refund {
            return refund.services.contains(service) ? .red.opacity(0.6) : .primary
        } else {
            return createdRefund.services.contains(service) ? .red : .primary
        }
    }
}
