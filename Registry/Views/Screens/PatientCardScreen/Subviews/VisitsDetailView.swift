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
        VStack {
            List {
                ForEach(uniqueDates, id: \.self) { date in
                    Section {
                        ForEach(visits.filter { $0.visitDate == date }) { visit in
                            visitView(visit)
                        }
                    } header: {
                        DateText(date, format: .weekDay)
                    }
                    .headerProminence(.increased)
                }
                .listRowSeparator(.hidden)
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
        Array(visits.map { $0.visitDate }.uniqued())
            .sorted(by: >)
    }
}

// MARK: - Subviews

private extension VisitsDetailView {
    func visitView(_ visit: Visit) -> some View {
        VStack(alignment: .leading) {
            if visit.refund == nil {
                HStack {
                    Text("Время записи:")
                    DateText(visit.visitDate, format: .time)
                }
                .font(.subheadline)
                .padding(4)
                .background(Color(.secondarySystemFill))
                .clipShape(.rect(cornerRadius: 4, style: .continuous))
            }

            if let cancellationDate = visit.cancellationDate {
                HStack {
                    Text("Отменен")
                    DateText(cancellationDate, format: .dateTime)
                }
                .font(.subheadline)
                .foregroundStyle(.red)
            } else if let bill = visit.bill {
                VStack(alignment: .leading) {
                    Text("Услуги")
                        .font(.headline)

                    ForEach(bill.services) { service in
                        Divider()
                        Text(service.pricelistItem.title)
                    }

                    Group {
                        if let refund = visit.refund {
                            Text("Возврат: \(Int(refund.price - refund.price * bill.discountRate)) ₽")
                                .foregroundStyle(.red)
                        } else {
                            if bill.discount > 0 {
                                Text("Скидка: \(Int(bill.discount)) ₽")
                            }
                            Text("Оплата: \(Int(bill.totalPrice)) ₽")
                        }

                    }
                    .fontWeight(.medium)
                    .padding(.top, 8)

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
                                    .padding(8)
                                    .background(.green)
                                    .clipShape(.capsule(style: .continuous))
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.tertiarySystemFill))
                .clipShape(.rect(cornerRadius: 8, style: .continuous))
            }

            HStack {
                Text(visit.refund == nil ? "Дата регистрации:" : "Дата возврата:")
                DateText(visit.registrationDate, format: .dateTime)
            }
            .font(.subheadline)
        }
    }
}
