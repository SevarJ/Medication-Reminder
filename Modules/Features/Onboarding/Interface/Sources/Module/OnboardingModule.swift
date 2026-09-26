//
//  OnboardingModule.swift
//  Onboarding
//
//  Created by Sevar Jafarli on 26.09.26.
//

import SwiftUI

public protocol OnboardingModule {
    associatedtype Screen: View

    @MainActor
    func pendingRoute() async -> OnboardingRoute?

    @MainActor
    func makeScreen(_ route: OnboardingRoute) -> Screen
}
