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

    init(patient: Patient, check: Check) {
        let contractBody = ContractBody(patient: patient, check: check)
        guard let date = check.payment?.date else { fatalError() }
        let pdfCreator = PDFCreator(date: date, body: contractBody)
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
        ContractScreen(patient: ExampleData.patient, check: ExampleData.check)
    }
    .navigationTitle("Договор")
    .navigationBarTitleDisplayMode(.inline)

}
