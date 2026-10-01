//
//  FirebaseConfiguratorTests.swift
//  FirebaseKitTests
//
//  Created by Sevar Jafarli on 01.10.26.
//

import DependencyInjection
import Domain
@testable import FirebaseKit
import Testing

struct FirebaseConfiguratorTests {
    @Test func registersAuthenticatorAndProfileRepository() {
        let container = DependencyContainer()

        FirebaseConfigurator.register(in: container)

        #expect(container.isRegistered((any AccountAuthenticating).self))
        #expect(container.isRegistered((any UserProfileRepository).self))
    }
}
