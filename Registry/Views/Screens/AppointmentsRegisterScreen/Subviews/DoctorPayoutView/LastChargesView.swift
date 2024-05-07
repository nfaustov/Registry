//
//  LastChargesView.swift
//  Registry
//
//  Created by Николай Фаустов on 02.05.2024.
//

import SwiftUI
import SwiftData

struct LastChargesView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    let doctor: Doctor

    // MARK: - State

    @State private var serviceChargesByDate: [Date: [ServiceCharge]] = [:]
    @State private var refundedServices: [MedicalService] = []
    @State private var isLoading: Bool = true

    // MARK:

    var body: some View {
        if !serviceChargesByDate.isEmpty || isLoading {
            DisclosureGroup {
                let dates = Array(serviceChargesByDate.keys.sorted(by: <))
                List(dates, id: \.self) { date in
                    DateText(date, format: .date)
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    let dateChargesByType = Dictionary(grouping: serviceChargesByDate[date] ?? [], by: { $0.type })
                    chargesView(dateChargesByType, ofType: .refill)
                    chargesView(dateChargesByType, ofType: .performed)
                    chargesView(dateChargesByType, ofType: .appointed)
                }
            } label: {
                lastChargesLabel
            }
            .onAppear {
                getServiceCharges()
            }
        }
    }
}

#Preview {
    LastChargesView(doctor: ExampleData.doctor)
}

// MARK: - Subviews

private extension LastChargesView {
    var lastChargesLabel: some View {
        HStack {
            Text("Последние зачисления")
                .foregroundStyle(isLoading ? .secondary : .primary)

            if isLoading {
                CircularProgressView()
                    .padding(.horizontal)
            }
        }
    }

    @ViewBuilder func chargesView(_ charges: [ServiceCharge.ServiceChargeType: [ServiceCharge]], ofType type: ServiceCharge.ServiceChargeType) -> some View {
        if let charges = charges[type]  {
            GroupBox(type.rawValue) {
                ForEach(charges) { serviceCharge in
                    LabeledContent(serviceCharge.serviceTitle, value: "\(Int(serviceCharge.value))")
                        .font(serviceCharge.type == .refill ? .title2 : .subheadline)
                        .foregroundStyle(serviceCharge.refunded ? .red.opacity(0.6) : .primary)
                }
            }
        }
    }
}

// MARK: - Calculations

private extension LastChargesView {
    func getLastPayoutDate() -> Date {
        let predicate = #Predicate<Payment> { $0.doctor == doctor }
        var descriptor = FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\.date, order: .reverse)])
        descriptor.fetchLimit = 1

        guard let lastPayout = try? modelContext.fetch(descriptor).first else { return .distantPast}

        return lastPayout.date
    }

    func getServiceCharges() {
        let lastPayoutDate = getLastPayoutDate()

        let performedServices = doctor.performedServices(from: lastPayoutDate)
        let appointedServices = doctor.appointedServices(from: lastPayoutDate)

        let performerCharges = performedServices
            .map { ServiceCharge(medicalService: $0, doctor: doctor, type: .performed) }
        let agentCharges = appointedServices
            .map { ServiceCharge(medicalService: $0, doctor: doctor, type: .appointed) }
        var serviceCharges = performerCharges
        serviceCharges.append(contentsOf: agentCharges)

        if let transactions = doctor.transactions {
            let lastTransactions = transactions.filter { $0.date > lastPayoutDate }
            let lastTransactionsCharges = lastTransactions.map { ServiceCharge(payment: $0) }
            serviceCharges.append(contentsOf: lastTransactionsCharges)
        }

        serviceChargesByDate = Dictionary(grouping: serviceCharges, by: { Calendar.current.startOfDay(for: $0.date) })

        let refundedPerformedServices = performedServices.filter { $0.refund != nil }
        let refundedAgentServices = appointedServices.filter { $0.refund != nil }
        refundedServices.append(contentsOf: refundedPerformedServices)
        refundedServices.append(contentsOf: refundedAgentServices)

        isLoading = false
    }
}

// MARK: - ServiceCharge

private struct ServiceCharge: Hashable, Identifiable {
    enum ServiceChargeType: String {
        case appointed = "Агент"
        case performed = "Исполнитель"
        case refill = "Пополнение"
    }

    let id: UUID
    let date: Date
    let type: ServiceChargeType
    let serviceTitle: String
    let value: Double
    let refunded: Bool

    init(id: UUID = UUID(), medicalService: MedicalService, doctor: Doctor, type: ServiceChargeType) {
        self.id = id
        date = medicalService.date ?? .now
        self.type = type
        serviceTitle = medicalService.pricelistItem.title

        switch type {
        case .appointed:
            value = medicalService.agentFee
        case .performed:
            if let rate = doctor.doctorSalary.rate {
                value = medicalService.pieceRateSalary(rate)
            } else {
                value = 0
            }
        default: value = 0
        }

        self.refunded = medicalService.refund != nil
    }

    init(id: UUID = UUID(), payment: Payment) {
        self.id = id
        date = payment.date
        type = .refill
        serviceTitle = ""
        value = payment.methods.reduce(0.0) { $0 + $1.value }
        refunded = false
    }
}
