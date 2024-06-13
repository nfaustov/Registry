//
//  ReportingGroupBoxStyle.swift
//  Registry
//
//  Created by Николай Фаустов on 12.06.2024.
//

import SwiftUI

struct ReportingGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
                .bold()
                .foregroundStyle(.secondary)
            configuration.content
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

extension GroupBoxStyle where Self == ReportingGroupBoxStyle {
    static var reporting: ReportingGroupBoxStyle { .init() }
}
