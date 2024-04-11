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
    let doctor: Doctor

    // MARK: - State

    @State private var renderedServices: [RenderedService] = []
    @State private var daySalary: Double = .zero
    @State private var isLoading: Bool = true
    @State private var isExpanded: Bool = false

    // MARK: -

    var body: some View {
        Section {
            if daySalary > 0 {
                DisclosureGroup(isExpanded: $isExpanded) {
                    List(renderedServices) { service in
                        LabeledContent(service.pricelistItem.title) {
                            if let fixedSalaryAmount = service.pricelistItem.salaryAmount {
                                Text("\(Int(fixedSalaryAmount)) ₽")
                                    .frame(width: 60)
                            } else if let rate = doctor.salary.rate {
                                Text("\(Int(service.pricelistItem.price * rate)) ₽")
                                    .frame(width: 60)
                            }
                        }
                        .font(.subheadline)
                    }
                } label: {
                    LabeledContent {
                        Text("\(Int(daySalary)) ₽")
                            .font(.headline)
                    } label: {
                        HStack {
                            Text("Заработано сегодня")

                            if isLoading {
                                CircularProgressView()
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
            }
        }
        .task {
            renderedServices = report.renderedServices(by: doctor, role: \.performer)
            daySalary = report.employeeSalary(doctor, from: renderedServices)
            isLoading = false
        }
    }
}

#Preview {
    DaySalaryView(report: ExampleData.report, doctor: ExampleData.doctor)
}
