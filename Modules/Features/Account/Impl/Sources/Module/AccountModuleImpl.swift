//
//  AccountModuleImpl.swift
//  AccountImpl
//
//  Created by Sevar Jafarli on 01.10.26.
//

import Account
import DependencyInjection
import Domain
import SwiftUI

struct AccountModuleImpl: AccountModule {
    private let authenticator: any AccountAuthenticating
    private let analytics: any AnalyticsTracking

    init(authenticator: any AccountAuthenticating = resolve(), analytics: any AnalyticsTracking = resolve()) {
        self.authenticator = authenticator
        self.analytics = analytics
    }

    @MainActor
    func makeScreen(_ route: AccountRoute) -> some View {
        switch route {
        case .signIn:
            SignInView(viewModel: SignInViewModel(authenticator: authenticator, analytics: analytics))
        }
    }
}
