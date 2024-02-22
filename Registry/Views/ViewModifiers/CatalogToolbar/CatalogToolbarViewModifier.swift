//
//  CatalogToolbarViewModifier.swift
//  Registry
//
//  Created by Николай Фаустов on 17.01.2024.
//

import SwiftUI

struct CatalogToolbarViewModifier: ViewModifier {
    var addAction: () -> Void

    func body(content: Content) -> some View {
        content
            .toolbar {
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

extension View {
    func catalogToolbar(addAction: @escaping () -> Void) -> some View {
        modifier(CatalogToolbarViewModifier(addAction: addAction))
    }
}
