//
//  ColoredIconButtonStyle.swift
//  Registry
//
//  Created by Николай Фаустов on 13.06.2024.
//

import SwiftUI

struct ColoredIconButtonStyle: ButtonStyle {
    // MARK: - Dependencies

    @Environment(\.isEnabled) private var isEnabled

    let color: Color

    // MARK: -

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .frame(width: 52, height: 52)
                .foregroundStyle(color.opacity(configuration.isPressed ? 0.5 : 0.1))
                .padding(.horizontal, 12)
            configuration.label
                .scaleEffect(configuration.isPressed ? 1.2 : 1)
                .foregroundStyle(color)
        }
        .saturation(isEnabled ? 1 : 0)
        .opacity(isEnabled ? 1 : 0.4)
    }
}
