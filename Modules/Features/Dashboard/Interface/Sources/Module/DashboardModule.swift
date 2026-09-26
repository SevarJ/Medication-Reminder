//
//  DashboardModule.swift
//  Dashboard
//
//  Created by Sevar Jafarli on 26.09.26.
//

import SwiftUI

public protocol DashboardModule {
    associatedtype Screen: View

    @MainActor
    func makeScreen(_ route: DashboardRoute) -> Screen
}
