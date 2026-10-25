//
//  OnboardingModule.swift
//  Onboarding
//
//  Created by Sevar Jafarli on 26.09.26.
//

import SwiftUI

public protocol OnboardingModule {
    associatedtype Screen: View

    /// The next step still to show at this stage, or nil once the stage is done. Ask again after each step finishes.
    @MainActor
    func pendingRoute(at stage: OnboardingStage) async -> OnboardingRoute?

    @MainActor
    func makeScreen(_ route: OnboardingRoute, onFinish: @escaping () -> Void) -> Screen
}
