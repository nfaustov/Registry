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

    @Environment(\.numPadStyle) private var numPadStyle

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
                decimalPointButton
                    .opacity(numPadStyle == .decimal ? 1 : 0)
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
            Label("", systemImage: "delete.backward")
                .labelStyle(.iconOnly)
                .font(.title2)
                .fontWeight(.light)
        }
        .buttonStyle(CustomButtonStyle())
        .disabled(text.isEmpty)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var decimalPointButton: some View {
        Button {
            AudioServicesPlaySystemSound(1104)
            if !text.contains(".") { text.append(".") }
        } label: {
            Text(".")
                .font(.largeTitle)
        }
        .buttonStyle(CustomButtonStyle())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func numButton(_ n: Int) -> some View {
        Button {
            AudioServicesPlaySystemSound(1104)
            text.append("\(n)")
        } label: {
            Text("\(n)")
                .font(.title)
                .fontWeight(.light)
        }
        .buttonStyle(CustomButtonStyle())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - CustomButtonStyle

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .frame(width: 80)
                .foregroundStyle(.ultraThinMaterial)
            configuration.label
        }
        .overlay {
            Circle()
                .foregroundStyle(.white.opacity(configuration.isPressed ? 0.6 : 0))
        }

    }
}

// MARK: - NumPadStyleKey

private struct NumPadStyleKey: EnvironmentKey {
    static let defaultValue: NumPadStyle = .integer
}

extension EnvironmentValues {
    var numPadStyle: NumPadStyle {
        get { self[NumPadStyleKey.self] }
        set { self[NumPadStyleKey.self] = newValue }
    }
}

enum NumPadStyle {
    case integer
    case decimal
}
