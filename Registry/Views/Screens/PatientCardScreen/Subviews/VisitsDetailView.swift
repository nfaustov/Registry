//
//  VisitsDetailView.swift
//  Registry
//
//  Created by Николай Фаустов on 21.02.2024.
//

import SwiftUI
import Algorithms

struct VisitsDetailView: View {
    // MARK: - Dependencies

    let visits: [Visit]

    // MARK: -

    var body: some View {
        List {
            ForEach(uniqueDates, id: \.self) { date in
                Section {
                    ForEach(visits.filter { Calendar.current.isDate($0.visitDate, inSameDayAs: date) }) { visit in
                        visitView(visit)
                    }
                } header: {
                    DateText(date, format: .weekDay)
                }
            }
        }
    }
}

#Preview {
    VisitsDetailView(visits: ExampleData.patient.visits)
}

// MARK: - Calculations

private extension VisitsDetailView {
    var uniqueDates: [Date] {
        Array(
            visits
                .map { Calendar.current.dateComponents([.year, .month, .day], from: $0.visitDate) }
                .map { Calendar.current.date(from: $0)! }
                .uniqued()
        )
        .sorted(by: >)
    }
}

// MARK: - Subviews

private extension VisitsDetailView {
    func visitView(_ visit: Visit) -> some View {
        Section {
            if let bill = visit.bill {
                DisclosureGroup {
                    ForEach(bill.services) { service in
                        LabeledContent(service.pricelistItem.title, value: "\(Int(service.pricelistItem.price)) ₽")
                    }

                    if bill.discount > 0 {
                        LabeledContent("Скидка", value: "\(Int(-bill.discount)) ₽")
                            .foregroundStyle(.blue)
                            .fontWeight(.light)
                    }
                } label: {
                    LabeledContent("Счет", value: "\(Int(bill.totalPrice)) ₽")
                        .font(.headline)
                        .foregroundStyle(.blue)
                }

                if let refund = visit.refund {
                    DisclosureGroup {
                        ForEach(refund.services) { service in
                            LabeledContent(service.pricelistItem.title, value: "\(Int(service.pricelistItem.price)) ₽")
                        }
                    } label: {
                        LabeledContent("Возврат", value: "\(Int(refund.price - refund.price * bill.discountRate)) ₽")
                            .font(.headline)
                            .foregroundStyle(.red)
                    }
                    .tint(.red)
                }

                if visit.refund == nil {
                    HStack {
                        let doctors = bill.services.compactMap { $0.performer }
                        let uniqueDoctors = Array(doctors.uniqued())

                        if uniqueDoctors.count > 0 {
                            Text(uniqueDoctors.count > 1 ? "Врачи:" : "Врач:")
                                .font(.headline)
                        }

                        ForEach(uniqueDoctors) { doctor in
                            Text(doctor.initials)
                                .foregroundStyle(.white)
                                .padding(4)
                                .background(.teal)
                                .clipShape(.rect(cornerRadius: 4, style: .continuous))
                        }
                    }
                }
            }

            LabeledContent("Дата регистрации") {
                DateText(visit.registrationDate, format: .dateTime)
            }

            LabeledContent("Регистратор", value: visit.registrar.initials)

            if let cancellationDate = visit.cancellationDate {
                LabeledContent("Отменен") {
                    DateText(cancellationDate, format: .dateTime)
                }
                .foregroundStyle(.brown)
                .listRowBackground(Color(.secondarySystemFill))
            }
        } header: {
            DateText(visit.visitDate, format: .time)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
}
