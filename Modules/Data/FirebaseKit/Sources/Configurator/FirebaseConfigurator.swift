//
//  FirebaseConfigurator.swift
//  FirebaseKit
//
//  Created by Sevar Jafarli on 01.10.26.
//

import DependencyInjection
import Domain
internal import FirebaseCore
import Foundation
internal import GoogleSignIn

public enum FirebaseConfigurator {
    /// Must run before anything resolves an account, profile or remote store dependency.
    public static func setup(in container: DependencyContainer = .shared) {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        register(in: container)
    }

    /// Hands the redirect that finishes a Google sign-in back to the SDK.
    @MainActor
    @discardableResult
    public static func open(_ url: URL) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }

    static func register(in container: DependencyContainer) {
        container.registerSingleton((any AccountAuthenticating).self) { FirebaseFactory.makeAuthenticator() }
        container.registerSingleton((any UserProfileRepository).self) { FirebaseFactory.makeProfileRepository() }
        container.registerSingleton((any MedicationRemoteStore).self) { FirebaseFactory.makeMedicationStore() }
        container.registerSingleton((any DoseLogRemoteStore).self) { FirebaseFactory.makeDoseLogStore() }
        container.registerSingleton((any RemoteOfflineStore).self) { FirebaseFactory.makeOfflineStore() }
    }
}
