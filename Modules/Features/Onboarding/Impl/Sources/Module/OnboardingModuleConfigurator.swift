//
//  OnboardingModuleConfigurator.swift
//  OnboardingImpl
//
//  Created by Sevar Jafarli on 26.09.26.
//

import Onboarding
import Paywall

public enum OnboardingModuleConfigurator {
    public static func makeModule(paywall: some PaywallModule) -> some OnboardingModule {
        OnboardingModuleImpl(paywall: paywall)
    }
}
