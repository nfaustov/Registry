//
//  ContractScreen.swift
//  Registry
//
//  Created by Николай Фаустов on 07.04.2024.
//

import SwiftUI
import PDFKit

struct ContractScreen: View {
    // MARK: - Dependencies

    private let pdfData: Data

    // MARK: - State

    @State private var showActivity: Bool = false

    // MARK: -

    init(patient: Patient, visit: Visit) {
        let contractBody = ContractBody(patient: patient, bill: visit.bill ?? Bill(services: []))
        let pdfCreator = PDFCreator(date: visit.visitDate, body: contractBody)
        pdfData = pdfCreator.createContract()
    }

    var body: some View {
        VStack {
            PDFDocumentView(pdfData: pdfData)
        }
        .ignoresSafeArea()
        .navigationTitle("Договор")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Button("", systemImage: "square.and.arrow.up") {
                    showActivity = true
                }
                .popover(isPresented: $showActivity) {
                    ActivityView(items: [pdfData])
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContractScreen(patient: ExampleData.patient, visit: ExampleData.visit)
    }
    .navigationTitle("Договор")
    .navigationBarTitleDisplayMode(.inline)

}
