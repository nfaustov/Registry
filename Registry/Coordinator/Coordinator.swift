//
//  Coordinator.swift
//  Registry
//
//  Created by Николай Фаустов on 22.12.2023.
//

import SwiftUI

final class Coordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var sheet: Sheet? = nil

    func push(_ route: Route) {
        path.append(route)
    }

    func present(_ sheet: Sheet) {
        self.sheet = sheet
    }

    func pop() {
        path.removeLast()
    }

    func clearPath() {
        path.removeLast(path.count)
    }
}

// MARK: - ViewBuilders

extension Coordinator {
    @ViewBuilder func setRootView(_ screen: Screen) -> some View {
        switch screen {
        case .specialists:
            DoctorsScreen()
        default:
            EmptyView()
        }
    }

    @ViewBuilder func destinationView(_ route: Route) -> some View {
        switch route {
        default: EmptyView()
        }
    }

    @ViewBuilder func sheetContent(_ sheet: Sheet) -> some View {
        switch sheet {
        case .createDoctor:
            CreateDoctorView()
        default: EmptyView()
        }
    }
}
