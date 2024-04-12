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
                    renderedServices = report.renderedServices(by: employee, role: \.performer)
                    daySalary = report.employeeSalary(employee, from: renderedServices)
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
