//
//  DaySalaryView.swift
//  Registry
//
//  Created by Николай Фаустов on 11.04.2024.
//

import SwiftUI
import SwiftData

struct DaySalaryView: View {
    // MARK: - Dependencies

    let doctor: Doctor

    // MARK: - State

    @State private var renderedServices: [MedicalService] = []
    @State private var refundedServices: [MedicalService] = []
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
                    let services = doctor.performedServices?.filter { service in
                        if let date = service.date {
                            return Calendar.current.isDateInToday(date)
                        } else { return false }
                    } ?? []
                    
                    if !services.isEmpty {
                        renderedServices = services
                        refundedServices = services.filter { $0.refund != nil }
                        daySalary = doctor.pieceRateSalary(for: services)
                    }

                    isLoading = false
                }
            } else if !renderedServices.isEmpty {
                DisclosureGroup(isExpanded: $isExpanded) {
                    List(renderedServices) { service in
                        LabeledContent(service.pricelistItem.title) {
                            if let fixedSalaryAmount = service.pricelistItem.fixedSalary {
                                Text("\(Int(fixedSalaryAmount)) ₽")
                                    .frame(width: 60)
                            } else if let rate = doctor.doctorSalary.rate {
                                Text("\(Int(service.pricelistItem.price * rate)) ₽")
                                    .frame(width: 60)
                            }
                        }
                        .font(.subheadline)
                        .foregroundStyle(refundedServices.contains(service) ? .red.opacity(0.6) : .primary)
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
    DaySalaryView(doctor: ExampleData.doctor)
}

// MARK: - Calculations

private extension DaySalaryView {
    func duplicateServices(in services: [MedicalService]) -> [MedicalService] {
        let duplicates = Dictionary(grouping: services, by: { $0.id })
            .filter { $1.count > 1 }
            .flatMap { $0.value }

        return Array(duplicates.uniqued())
    }

    func singleCopyServices(in services: [MedicalService]) -> [MedicalService] {
        Dictionary(grouping: services, by: { $0.id })
            .filter { $1.count == 1 }
            .flatMap { $0.value }
    }
}
