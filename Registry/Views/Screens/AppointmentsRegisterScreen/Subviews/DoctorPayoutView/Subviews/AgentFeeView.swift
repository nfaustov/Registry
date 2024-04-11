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

    @State private var servicesByAgent: [Date: [RenderedService]] = [:]
    @State private var isLoading: Bool = false
    @State private var isExpanded: Bool = false

    // MARK: -

    var body: some View {
        Section {
            if doctor.agentFee > 0 {
                DisclosureGroup(isExpanded: $isExpanded) {
                    List(Array(servicesByAgent.keys.sorted(by: <)), id: \.self) { date in
                        DateText(date, format: .date)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        ForEach(servicesByAgent[date] ?? []) { service in
                            LabeledContent(
                                service.pricelistItem.title,
                                value: "\(Int(service.pricelistItem.price * 0.1)) ₽"
                            )
                            .font(.subheadline)
                        }
                    }
                } label: {
                    agentFeeTitle
                }
                .onChange(of: isExpanded) { _, newValue in
                    if newValue, servicesByAgent.isEmpty {
                        isLoading = true

                        Task {
                            await getAgentServices()
                            isLoading = false
                        }
                    }
                }

                Button("Выплатить") {
                    doctor.agentFeePayment()
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

// MARK: - Calculations

private extension AgentFeeView {
    func getAgentServices() async {
        let now = Date.now
        let agentFeePaymentDate = doctor.agentFeePaymentDate
        let predicate = #Predicate<Report> { $0.date > agentFeePaymentDate && $0.date < now }
        let descriptor = FetchDescriptor<Report>(predicate: predicate, sortBy: [SortDescriptor(\Report.date, order: .reverse)])

        if let reports = try? modelContext.fetch(descriptor) {
            servicesByAgent = await withTaskGroup(
                of: (Date, [RenderedService]).self,
                returning: [Date: [RenderedService]].self
            ) { taskGroup in
                for report in reports {
                    taskGroup.addTask {
                        let services = report.renderedServices(by: doctor, role: \.agent)
                        return (report.date, services)
                    }
                }

                var dict = [Date: [RenderedService]]()

                for await (date, services) in taskGroup {
                    if !services.isEmpty {
                        dict[date] = services
                    }
                }

                return dict
            }
        }
    }
}
