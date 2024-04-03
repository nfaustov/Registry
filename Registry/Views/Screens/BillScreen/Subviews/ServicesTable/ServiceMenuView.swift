//
//  ServiceMenuView.swift
//  Registry
//
//  Created by Николай Фаустов on 27.02.2024.
//

import SwiftUI
import SwiftData

struct ServiceMenuView: View {
    // MARK: - Dependencies

    @Query private var doctors: [Doctor]

    @Binding var bill: Bill

    let serviceID: RenderedService.ID

    // MARK: -

    var body: some View {
        Section {
            menu(of: \.performer)
                .disabled(service.pricelistItem.category == .laboratory)
            menu(of: \.agent)
        }

        Section {
            Button(role: .destructive) {
                withAnimation {
                    bill.services.removeAll(where: { $0.id == serviceID })
                }
            } label: {
                Label("Удалить", systemImage: "trash")
            }
        }    }
}

#Preview {
    ServiceMenuView(bill: .constant(Bill(services: [])), serviceID: UUID())
}

// MARK: - Subviews

private extension ServiceMenuView {
    func menu(of kind: WritableKeyPath<RenderedService, AnyEmployee?>) -> some View {
        Menu(kind == \.performer ? "Исполнитель" : "Агент") {
            doctorButton(nil, role: kind)
            ForEach(doctors) { doctor in
                doctorButton(doctor, role: kind)
            }
        }
    }

    func doctorButton(_ doctor: Doctor?, role: WritableKeyPath<RenderedService, AnyEmployee?>) -> some View {
        Button(doctor?.initials ?? "-") {
            withAnimation {
                var updatedService = service
                updatedService[keyPath: role] = doctor?.employee
                bill.services.replace([service], with: [updatedService])
            }
        }
    }
}

// MARK: - Calculations

private extension ServiceMenuView {
    var service: RenderedService {
        guard let service = bill.services.first(where: { $0.id == serviceID }) else { fatalError() }
        return service
    }
}
