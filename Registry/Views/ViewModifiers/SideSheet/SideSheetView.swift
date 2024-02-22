//
//  SideSheetView.swift
//  Registry
//
//  Created by Николай Фаустов on 06.01.2024.
//

import SwiftUI

struct SideSheetView<Content: View>: View {
    @State private var alignment: Alignment = .trailing
    @State private var offset: CGSize = CGSize(width: 0, height: 1000)

    @Binding var isPresented: Bool

    private let content: Content

    init(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        _isPresented = isPresented
        self.content = content()
    }

    var body: some View {
        GeometryReader { geometry in
            if geometry.size != .zero {
                ZStack(alignment: alignment) {
                    Color.clear

                    ZStack(alignment: .top) {
                        content
                            .padding(.top, 38)

                        Image(systemName: "ellipsis")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.secondary)
                            .background(.ultraThickMaterial, in: Rectangle())
                            .gesture(
                                DragGesture(coordinateSpace: .global)
                                    .onChanged { value in
                                        if value.translation.height > 0 {
                                            offset.height = value.translation.height * 0.8
                                        }
                                        if alignment == .trailing, value.translation.width < 0 {
                                            offset.width = value.translation.width * 0.8
                                        } else if alignment == .leading, value.translation.width > 0 {
                                            offset.width = value.translation.width * 0.8
                                        }
                                    }
                                    .onEnded { value in
                                        if offset.height > 240 {
                                            withAnimation {
                                                isPresented = false
                                            }
                                        }
                                        replace(width: offset.width)
                                        offset = .zero
                                    }
                            )
                    }
                    .frame(width: 400)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(
                        Color(.systemFill),
                        in: RoundedRectangle(cornerRadius: 8, style: .continuous).stroke()
                    )
                    .offset(offset)
                    .shadow(color: .black.opacity(0.05), radius: 12, x: alignment == .trailing ? -8 : 8, y: 10)
                    .padding()
                    .animation(.spring(dampingFraction: 0.9), value: offset)
                    .onAppear {
                        offset.height = geometry.size.height + geometry.safeAreaInsets.bottom
                    }
                    .onChange(of: isPresented) { _, newValue in
                        if newValue {
                            offset = .zero
                        } else {
                            offset.height = geometry.size.height + geometry.safeAreaInsets.bottom
                        }
                    }
                }
            } else {
                EmptyView()
            }
        }
    }

    private func replace(width: CGFloat) {
        switch width {
        case -700...(-240):
            alignment = .leading
        case 240...700:
            alignment = .trailing
        default:
            break
        }
    }
}

extension View {
    func sideSheet<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        ZStack {
            self
            SideSheetView(isPresented: isPresented, content: content)
        }
    }
}
