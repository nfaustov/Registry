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

                            LabeledContent(
                                service.pricelistItem.title,
                                value: "\(Int(service.pricelistItem.price))"
                            )
                            .foregroundStyle(serviceItemForegroudColor(service))
                        }
                    }
                } header: {
                    HStack {
                        Text(editMode ? "Выберите услуги" : "Услуги")
                    }
                }

                Section("Итог") {
                    LabeledContent("Цена", value: "\(Int(appointment.check?.price ?? 0)) ₽")

                    if let discount = appointment.check?.discount, discount != 0 {
                        LabeledContent("Скидка", value: "\(Int(discount)) ₽")
                    }
                }

                Section("Оплата") {
                    if let payment = appointment.check?.payment {
                        ForEach(payment.methods, id: \.self) { method in
                            LabeledContent(method.type.rawValue, value: "\(Int(method.value)) ₽")
                        }
                        LabeledContent("Всего", value: "\(Int(payment.totalAmount)) ₽")
                            .font(.headline)
                    }
                }

                if let refund = appointment.check?.refund {
                    LabeledContent("Возврат", value: "\(Int(refund.totalAmount)) ₽")
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
                    let ledger = Ledger(modelContainer: modelContext.container)

                    if let check = appointment.check {
                        await ledger.makeRefundPayment(createdRefund, to: check, method: paymentMethod, createdBy: user)
                    }

                    if includeBalance {
                        await ledger.makeBalancePayment(from: patient, value: -patient.balance, createdBy: user)
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
                LabeledContent("Возврат", value: "\(Int(refundTotalAmount)) ₽")
                    .font(.headline)
                    .foregroundStyle(.red)

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
