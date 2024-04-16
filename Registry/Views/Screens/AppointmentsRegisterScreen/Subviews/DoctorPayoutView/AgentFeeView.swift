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

    @State private var agentServicesByDate: [Date: [RenderedService]] = [:]
    @State private var refundedServicesIDs: [RenderedService.ID] = []
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
                            LabeledContent(
                                service.pricelistItem.title,
                                value: "\(Int(service.pricelistItem.price * 0.1)) ₽"
                            )
                            .font(.subheadline)
                            .foregroundStyle(refundedServicesIDs.contains(service.id) ? .red.opacity(0.6) : .primary)
                        }
                    }
                } label: {
                    agentFeeTitle
                }
                .onChange(of: isExpanded) { _, newValue in
                    if newValue, agentServicesByDate.isEmpty {
                        isLoading = true

                        Task {
                            await getAgentServices()
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

// MARK: - Calculations

private extension AgentFeeView {
    func getAgentServices() async {
        let now = Date.now
        let startOfAgentFeePaymentDate = Calendar.current.startOfDay(for: doctor.agentFeePaymentDate)
        let predicate = #Predicate<Report> { $0.date >= startOfAgentFeePaymentDate && $0.date < now }
        let descriptor = FetchDescriptor<Report>(predicate: predicate, sortBy: [SortDescriptor(\Report.date, order: .reverse)])

        if let reports = try? modelContext.fetch(descriptor) {
            agentServicesByDate = await withTaskGroup(
                of: (Date, [RenderedService]).self,
                returning: [Date: [RenderedService]].self
            ) { taskGroup in
                for report in reports {
                    taskGroup.addTask {
                        let services = agentServices(from: report)
                        let renderedServices = Array(services.uniqued())
                        let reportRefundedServicesIDs = duplicateServices(in: services).map { $0.id }
                        refundedServicesIDs.append(contentsOf: reportRefundedServicesIDs)

                        return (report.date, renderedServices)
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

    func agentServices(from report: Report) -> [RenderedService] {
        if Calendar.current.isDate(report.date, inSameDayAs: doctor.agentFeePaymentDate) {
            return report.services(by: doctor, role: \.agent, fromDate: doctor.agentFeePaymentDate)
        } else {
            return report.services(by: doctor, role: \.agent)
        }
    }

    func duplicateServices(in services: [RenderedService]) -> [RenderedService] {
        let duplicates = Dictionary(grouping: services, by: { $0.id })
            .filter { $1.count > 1 }
            .flatMap { $0.value }

        return Array(duplicates.uniqued())
    }
}
