//
//  BillTemplatesController.swift
//  Registry
//
//  Created by Николай Фаустов on 02.04.2024.
//

import SwiftUI
import SwiftData

struct BillTemplatesController: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    @Query private var billTemplates: [BillTemplate]

    // MARK: -

    var body: some View {
        VStack(alignment: .leading) {
            Text("Шаблоны")
                .font(.title)
                .padding(.bottom, 20)

            List(billTemplates) { template in
                Text(template.title)
                    .swipeActions(edge: .trailing) {
                        trailingSwipeAction(for: template)
                    }
            }
            .padding()
        }
    }
}

#Preview {
    BillTemplatesController()
}

// MARK: - Subviews

private extension BillTemplatesController {
    func trailingSwipeAction(for template: BillTemplate) -> some View {
        Button(role: .destructive) {
            modelContext.delete(template)
        } label: {
            Label("Удалить", systemImage: "trash")
        }
    }
}
