//
//  OnboardingRoute.swift
//  Onboarding
//
//  Created by Sevar Jafarli on 26.09.26.
//

public enum OnboardingRoute: Hashable, Identifiable, Sendable {
    case introduction
    case notificationPriming

    public var id: Self { self }
}
