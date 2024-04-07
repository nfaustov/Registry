//
//  PDFCreator.swift
//  Registry
//
//  Created by Николай Фаустов on 07.04.2024.
//

import PDFKit

final class PDFCreator: NSObject {
    private let title: String
    private let body: ContractBody
    private let date: Date

    init(
        title: String = "ДОГОВОР ОБ ОКАЗАНИИ ПЛАТНЫХ МЕДИЦИНСКИХ УСЛУГ",
        date: Date,
        body: ContractBody
    ) {
        self.title = title
        self.date = date
        self.body = body
    }

    func createContract() -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "Document Builder",
            kCGPDFContextAuthor: "ООО УльтраМед",
            kCGPDFContextTitle: title
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let data = renderer.pdfData { context in
            context.beginPage()
            addIdentifier(pageRect: pageRect)
            let titleBottom = addTitle(pageRect: pageRect)
            addCityName(pageRect: pageRect, cityNameTop: titleBottom + 5)
            let dateBottom = addDate(pageRect: pageRect, dateTop: titleBottom + 5)
            body.makeFirstPage(context.cgContext, pageRect: pageRect, textTop: dateBottom + 10)

            context.beginPage()
            body.makeSecondPage(context.cgContext, pageRect: pageRect, textTop: 30)
        }

        return data
    }

    private func addTitle(pageRect: CGRect) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 14.0, weight: .bold)
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
        let attributedTitle = NSAttributedString(
            string: title,
            attributes: titleAttributes
        )
        let titleStringSize = attributedTitle.size()
        let titleStringRect = CGRect(
            x: (pageRect.width - titleStringSize.width) / 2.0,
            y: 30,
            width: titleStringSize.width,
            height: titleStringSize.height
        )
        attributedTitle.draw(in: titleStringRect)

        return titleStringRect.maxY
    }

    private func addIdentifier(pageRect: CGRect) {
        let identifierFont = UIFont.systemFont(ofSize: 6)
        let attributes: [NSAttributedString.Key: Any] = [.font: identifierFont]
        let identifier = "ID: \(UUID().uuidString)"
        let attributedIdentifier = NSAttributedString(string: identifier, attributes: attributes)
        let identifierStringSize = attributedIdentifier.size()
        let identifierStringRect = CGRect(
            x: pageRect.width - identifierStringSize.width - 30,
            y: 15,
            width: identifierStringSize.width,
            height: identifierStringSize.height
        )
        attributedIdentifier.draw(in: identifierStringRect)
    }

    private func addCityName(pageRect: CGRect, cityNameTop: CGFloat) {
        let cityNameFont = UIFont.systemFont(ofSize: 8, weight: .regular)
        let cityNameAttributes: [NSAttributedString.Key: Any] = [.font: cityNameFont]
        let attributedCityName = NSAttributedString(string: "г. Липецк", attributes: cityNameAttributes)
        let cityNameStringSize = attributedCityName.size()
        let cityNameRect = CGRect(
            x: 30,
            y: cityNameTop,
            width: cityNameStringSize.width,
            height: cityNameStringSize.height
        )
        attributedCityName.draw(in: cityNameRect)
    }

    private func addDate(pageRect: CGRect, dateTop: CGFloat) -> CGFloat {
        let dateFont = UIFont.systemFont(ofSize: 8, weight: .regular)
        let dateAttributes: [NSAttributedString.Key: Any] = [.font: dateFont]
        let dateString = DateFormat.date.string(from: date)
        let attributedDate = NSAttributedString(string: dateString, attributes: dateAttributes)
        let dateStringSize = attributedDate.size()
        let dateStringRect = CGRect(
            x: pageRect.width - dateStringSize.width - 30,
            y: dateTop,
            width: dateStringSize.width,
            height: dateStringSize.height
        )
        attributedDate.draw(in: dateStringRect)

        return dateStringRect.maxY
    }
}
