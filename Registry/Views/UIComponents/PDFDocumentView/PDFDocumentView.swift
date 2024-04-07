//
//  PDFDocumentView.swift
//  Registry
//
//  Created by Николай Фаустов on 07.04.2024.
//

import SwiftUI
import PDFKit

struct PDFDocumentView: UIViewRepresentable {
    private let pdfDocument: PDFDocument

    init(pdfData: Data) {
        pdfDocument = PDFDocument(data: pdfData) ?? PDFDocument()
    }

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = pdfDocument
        pdfView.autoScales = true

        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = pdfDocument
    }
}
