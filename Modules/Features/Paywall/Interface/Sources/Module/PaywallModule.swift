//
//  PaywallModule.swift
//  Paywall
//
//  Created by Sevar Jafarli on 25.10.26.
//

import SwiftUI

public protocol PaywallModule {
    associatedtype Screen: View

    @MainActor
    func makeScreen(_ route: PaywallRoute, onFinish: @escaping () -> Void) -> Screen
}
