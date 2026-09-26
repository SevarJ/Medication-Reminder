//
//  OnboardingModule.swift
//  OnboardingImpl
//
//  Created by Sevar Jafarli on 26.09.26.
//

import SwiftUI

public enum OnboardingModule {
    @MainActor
    public static func shouldShowNotificationPriming() async -> Bool {
        await OnboardingModuleImpl().shouldShowNotificationPriming()
    }

    @MainActor
    public static func makeNotificationPrimingView(onFinish: @escaping () -> Void) -> some View {
        OnboardingModuleImpl().makeNotificationPrimingView(onFinish: onFinish)
    }
}
