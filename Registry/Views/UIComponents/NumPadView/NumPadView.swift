//
//  NumPadView.swift
//  Registry
//
//  Created by Николай Фаустов on 09.04.2024.
//

import SwiftUI
import AudioToolbox

struct NumPadView: View {
    // MARK: - Dependencies

    @Binding var text: String

    // MARK: -

    var body: some View {
        VStack {
            HStack {
                numButton(1)
                numButton(2)
                numButton(3)
            }

            HStack {
                numButton(4)
                numButton(5)
                numButton(6)
            }

            HStack {
                numButton(7)
                numButton(8)
                numButton(9)
            }

            HStack {
                numButton(0).opacity(0)
                numButton(0)
                deleteButton
            }
        }
    }
}

#Preview {
    NumPadView(text: .constant(""))
        .background(.blue.opacity(0.4))
}

// MARK: - Subviews

private extension NumPadView {
    private var deleteButton: some View {
        Button {
            AudioServicesPlaySystemSound(1104)
            text.removeLast()
        } label: {
            ZStack {
                Circle()
                    .frame(width: 80)
                    .foregroundStyle(.ultraThinMaterial)
                Label("", systemImage: "delete.backward")
                    .labelStyle(.iconOnly)
                    .font(.title2)
                    .fontWeight(.light)
            }
        }
        .buttonStyle(CustomButtonStyle())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func numButton(_ n: Int) -> some View {
        Button {
            AudioServicesPlaySystemSound(1104)
            text.append("\(n)")
        } label: {
            ZStack {
                Circle()
                    .frame(width: 80)
                    .foregroundStyle(.ultraThinMaterial)
                Text("\(n)")
                    .font(.title)
                    .fontWeight(.light)
            }
        }
        .buttonStyle(CustomButtonStyle())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - CustomButtonStyle

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay {
                Circle()
                    .foregroundStyle(.white.opacity(configuration.isPressed ? 0.6 : 0))
            }
    }
}
