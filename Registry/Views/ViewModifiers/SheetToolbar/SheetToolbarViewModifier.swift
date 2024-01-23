//
//  SheetToolbarViewModifier.swift
//  Registry
//
//  Created by Николай Фаустов on 06.01.2024.
//

import SwiftUI

struct SheetToolbarViewModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss

    var title: String
    var subtitle: String? = nil
    var confirmationDisabled: Bool = false
    var confirmationAction: (() -> Void)? = nil

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text(confirmationAction == nil ? "Закрыть" : "Отменить")
                    }
                }
                if let onConfirm = confirmationAction {
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            onConfirm()
                            dismiss()
                        } label: {
                            Text("Подтвердить")
                        }
                        .disabled(confirmationDisabled)
                    }
                }
            }
            .navTitle(title: title, subTitle: subtitle)
    }
}

extension View {
    func sheetToolbar(
        title: String,
        subtitle: String? = nil,
        confirmationDisabled: Bool = false,
        onConfirm: (() -> Void)? = nil
    ) -> some View {
        modifier(SheetToolbarViewModifier(
            title: title,
            subtitle: subtitle,
            confirmationDisabled: confirmationDisabled,
            confirmationAction: onConfirm
        ))
    }
}
