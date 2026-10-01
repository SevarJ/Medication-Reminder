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

    init(authenticator: any AccountAuthenticating = resolve()) {
        self.authenticator = authenticator
    }

    @MainActor
    func makeScreen(_ route: AccountRoute) -> some View {
        switch route {
        case .signIn:
            SignInView(viewModel: SignInViewModel(authenticator: authenticator))
        }
    }
}
