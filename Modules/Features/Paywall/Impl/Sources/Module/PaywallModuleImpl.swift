//
//  PaywallModuleImpl.swift
//  PaywallImpl
//
//  Created by Sevar Jafarli on 25.10.26.
//

import DependencyInjection
import Domain
import Paywall
import SwiftUI

struct PaywallModuleImpl: PaywallModule {
    private let entitlements: any EntitlementProviding
    private let authenticator: any AccountAuthenticating
    private let analytics: any AnalyticsTracking

    init(
        entitlements: any EntitlementProviding = resolve(),
        authenticator: any AccountAuthenticating = resolve(),
        analytics: any AnalyticsTracking = resolve()
    ) {
        self.entitlements = entitlements
        self.authenticator = authenticator
        self.analytics = analytics
    }

    @MainActor
    func makeScreen(_ route: PaywallRoute, onFinish: @escaping () -> Void) -> some View {
        switch route {
        case .onboarding, .settings:
            PaywallView(
                viewModel: PaywallViewModel(entitlements: entitlements, authenticator: authenticator, analytics: analytics),
                onFinish: onFinish
            )
        }
    }
}
