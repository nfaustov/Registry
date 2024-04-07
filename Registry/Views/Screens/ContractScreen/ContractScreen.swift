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

    let contractBody: ContractBody
    let date: Date

    // MARK: -

    var body: some View {
        VStack {
            let pdfCreator = PDFCreator(date: date, body: contractBody)
            PDFDocumentView(pdfData: pdfCreator.createContract())
        }
    }
}

#Preview {
    ContractScreen(contractBody: .init(patient: ExampleData.patient, bill: Bill(services: [ExampleData.service], discount: 200)), date: .now)
}
