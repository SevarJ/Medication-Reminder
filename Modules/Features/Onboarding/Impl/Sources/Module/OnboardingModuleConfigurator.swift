//
//  OnboardingModuleConfigurator.swift
//  OnboardingImpl
//
//  Created by Sevar Jafarli on 26.09.26.
//

import Onboarding

public enum OnboardingModuleConfigurator {
    public static func makeModule() -> some OnboardingModule {
        OnboardingModuleImpl()
    }
}
