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

    @Query private var checkTemplates: [CheckTemplate]

    // MARK: -

    var body: some View {
        VStack(alignment: .leading) {
            Text("Шаблоны")
                .font(.title)
                .padding(.bottom, 20)

            List(checkTemplates) { template in
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
    func trailingSwipeAction(for template: CheckTemplate) -> some View {
        Button(role: .destructive) {
            modelContext.delete(template)
        } label: {
            Label("Удалить", systemImage: "trash")
        }
    }
}
