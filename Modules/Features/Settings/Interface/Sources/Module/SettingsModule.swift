//
//  SettingsModule.swift
//  Settings
//
//  Created by Sevar Jafarli on 26.09.26.
//

import SwiftUI

public protocol SettingsModule {
    associatedtype Screen: View

    @MainActor
    func makeScreen(_ route: SettingsRoute) -> Screen
}
