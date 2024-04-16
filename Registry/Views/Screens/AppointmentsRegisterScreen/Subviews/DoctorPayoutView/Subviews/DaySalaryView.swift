//
//  DaySalaryView.swift
//  Registry
//
//  Created by Николай Фаустов on 11.04.2024.
//

import SwiftUI

struct DaySalaryView: View {
    // MARK: - Dependencies

    let report: Report
    let employee: Employee

    // MARK: - State

    @State private var renderedServices: [RenderedService] = []
    @State private var refundedServicesIDs: [RenderedService.ID] = []
    @State private var daySalary: Double = .zero
    @State private var isLoading: Bool = true
    @State private var isExpanded: Bool = false

    // MARK: -

    var body: some View {
        Section {
            if isLoading {
                HStack {
                    Text("Оказанные услуги")
                        .foregroundStyle(.secondary)
                    
                    CircularProgressView()
                        .padding(.horizontal)
                }
                .task {
                    let services = report.services(by: employee, role: \.performer)
                    renderedServices = Array(services.uniqued())
                    refundedServicesIDs = duplicateServices(in: services).map { $0.id }
                    let balancedServices = singleCopyServices(in: services)
                    daySalary = report.employeeSalary(employee, from: balancedServices)
                    isLoading = false
                }
            } else if !renderedServices.isEmpty {
                DisclosureGroup(isExpanded: $isExpanded) {
                    List(renderedServices) { service in
                        LabeledContent(service.pricelistItem.title) {
                            if let fixedSalaryAmount = service.pricelistItem.salaryAmount {
                                Text("\(Int(fixedSalaryAmount)) ₽")
                                    .frame(width: 60)
                            } else if let rate = employee.salary.rate {
                                Text("\(Int(service.pricelistItem.price * rate)) ₽")
                                    .frame(width: 60)
                            }
                        }
                        .font(.subheadline)
                        .foregroundStyle(refundedServicesIDs.contains(service.id) ? .red.opacity(0.6) : .primary)
                    }
                } label: {
                    LabeledContent {
                        if daySalary > 0 {
                            Text("\(Int(daySalary)) ₽")
                                .font(.headline)
                        }
                    } label: {
                        Text(daySalary > 0 ? "Заработано сегодня" : "Оказанные услуги")
                    }
                }
            }
        }
    }
}

#Preview {
    DaySalaryView(report: ExampleData.report, employee: ExampleData.doctor)
}

// MARK: - Calculations

private extension DaySalaryView {
    func duplicateServices(in services: [RenderedService]) -> [RenderedService] {
        let duplicates = Dictionary(grouping: services, by: { $0.id })
            .filter { $1.count > 1 }
            .flatMap { $0.value }

        return Array(duplicates.uniqued())
    }

    func singleCopyServices(in services: [RenderedService]) -> [RenderedService] {
        Dictionary(grouping: services, by: { $0.id })
            .filter { $1.count == 1 }
            .flatMap { $0.value }
    }
}
