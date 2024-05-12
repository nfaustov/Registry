//
//  SheetToolbarViewModifier.swift
//  Registry
//
//  Created by Николай Фаустов on 06.01.2024.
//

import SwiftUI

struct SheetToolbarViewModifier: ViewModifier {
    //MARK: - Dependencies

    @Environment(\.dismiss) private var dismiss

    var title: String
    var subtitle: String? = nil
    var disabled: Bool = false
    var onConfirm: (() -> Void)? = nil
    var onAsyncConfirm: (() async -> Void)? = nil

    //MARK: - State

    @State private var inProcess: Bool = false

    // MARK: -

    init(_ title: String, subtitle: String? = nil, disabled: Bool = false, onConfirm: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.disabled = disabled
        self.onConfirm = onConfirm
        onAsyncConfirm = nil
    }

    init(_ title: String, subtitle: String? = nil, disabled: Bool = false, onAsyncConfirm: (() async -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.disabled = disabled
        self.onAsyncConfirm = onAsyncConfirm
        onConfirm = nil
    }

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text(onConfirm == nil ? "Закрыть" : "Отменить")
                    }
                }

                if let onConfirm {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Подтвердить") {
                            onConfirm()
                            dismiss()
                        }
                        .disabled(disabled)
                    }
                } else if let onAsyncConfirm {
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            inProcess = true

                            Task(priority: .userInitiated) {
                                await onAsyncConfirm()
                                inProcess = false
                                dismiss()
                            }
                        } label: {
                            if inProcess {
                                CircularProgressView()
                                    .padding(.horizontal)
                            } else {
                                Text("Подтвердить")
                            }
                        }
                        .disabled(disabled)
                    }
                }
            }
            .navTitle(title: title, subTitle: subtitle)
    }
}

extension View {
    func sheetToolbar(
        _ title: String,
        subtitle: String? = nil,
        disabled: Bool = false,
        onConfirm: (() -> Void)? = nil
    ) -> some View {
        modifier(SheetToolbarViewModifier(
            title,
            subtitle: subtitle,
            disabled: disabled,
            onConfirm: onConfirm
        ))
    }

    func sheetToolbar(
        _ title: String,
        subtitle: String? = nil,
        disabled: Bool = false,
        task: (() async -> Void)? = nil
    ) -> some View {
        modifier(SheetToolbarViewModifier(
            title,
            subtitle: subtitle,
            disabled: disabled,
            onAsyncConfirm: task
        ))
    }
}
