//
//  CatalogToolbarViewModifier.swift
//  Registry
//
//  Created by Николай Фаустов on 17.01.2024.
//

import SwiftUI

struct CatalogToolbarViewModifier: ViewModifier {
    // MARK: - Dependencies

    @Environment(\.user) private var user

    var addAction: () -> Void

    // MARK: -

    func body(content: Content) -> some View {
        content
            .toolbar {
                if user.accessLevel == .boss {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            addAction()
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(.blue.gradient)
                                .cornerRadius(8)
                        }
                        .padding()
                    }
                }
            }
    }
}

extension View {
    func catalogToolbar(addAction: @escaping () -> Void) -> some View {
        modifier(CatalogToolbarViewModifier(addAction: addAction))
    }
}
