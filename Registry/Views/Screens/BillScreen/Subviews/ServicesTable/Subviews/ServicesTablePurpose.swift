//
//  ServicesTablePurpose.swift
//  Registry
//
//  Created by Николай Фаустов on 20.05.2024.
//

import SwiftUI

enum ServicesTablePurpose {
    case createAndPay
    case editRoles
}

private struct ServicesTablePurposeKey: EnvironmentKey {
    static var defaultValue: ServicesTablePurpose = .createAndPay
}

extension EnvironmentValues {
    var servicesTablePurpose: ServicesTablePurpose {
        get { self[ServicesTablePurposeKey.self] }
        set { self[ServicesTablePurposeKey.self] = newValue }
    }
}

extension View {
    func servicesTablePurpose(_ purpose: ServicesTablePurpose) -> some View {
        environment(\.servicesTablePurpose, purpose)
    }
}
