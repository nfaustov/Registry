//
//  AgentFeeView.swift
//  Registry
//
//  Created by Николай Фаустов on 11.04.2024.
//

import SwiftUI
import SwiftData

struct AgentFeeView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    let doctor: Doctor

    // MARK: - State

    @State private var agentServicesByDate: [Date: [MedicalService]] = [:]
    @State private var refundedServices: [MedicalService] = []
    @State private var isLoading: Bool = false
    @State private var isExpanded: Bool = false

    // MARK: -

    var body: some View {
        Section {
            if doctor.agentFee > 0 {
                DisclosureGroup(isExpanded: $isExpanded) {
                    List(Array(agentServicesByDate.keys.sorted(by: <)), id: \.self) { date in
                        DateText(date, format: .date)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        ForEach(agentServicesByDate[date] ?? []) { service in
                            let value = service.pricelistItem.fixedAgentFee ?? service.pricelistItem.price * 0.1
                            LabeledContent(service.pricelistItem.title, value: "\(Int(value)) ₽")
                                .font(.subheadline)
                                .foregroundStyle(refundedServices.contains(service) ? .red.opacity(0.6) : .primary)
                        }
                    }
                } label: {
                    agentFeeTitle
                }
                .onChange(of: isExpanded) { _, newValue in
                    if newValue, agentServicesByDate.isEmpty {
                        isLoading = true

                        Task {
                            let services = doctor.lastAppointedServices

                            if !services.isEmpty {
                                refundedServices = services.filter { $0.refund != nil }
                                agentServicesByDate = Dictionary(grouping: services, by: { $0.date ?? .now })
                            }

                            isLoading = false
                        }
                    }
                }
            } else {
                agentFeeTitle
            }
        }
    }
}

#Preview {
    AgentFeeView(doctor: ExampleData.doctor)
}

// MARK: - Subviews

private extension AgentFeeView {
    var agentFeeTitle: some View {
        LabeledContent {
            Text("\(Int(doctor.agentFee)) ₽")
                .font(.headline)
        } label: {
            HStack {
                Text("Агентские")

                if isLoading {
                    CircularProgressView()
                        .padding(.horizontal)
                }
            }
        }
    }
}
