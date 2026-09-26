//
//  NotificationPrimingModifier.swift
//  OnboardingImpl
//
//  Created by Sevar Jafarli on 26.09.26.
//

import Onboarding
import SwiftUI

struct NotificationPrimingModifier: ViewModifier {
    @State private var model: NotificationPrimingModel

    init(dependencies: OnboardingDependencies) {
        _model = State(
            initialValue: NotificationPrimingModel(
                authorizer: dependencies.authorizer,
                syncReminder: dependencies.syncReminder,
                preferences: dependencies.preferences
            )
        )
    }

    func body(content: Content) -> some View {
        content
            .sheet(
                isPresented: Binding(
                    get: { model.isPresented },
                    set: { if !$0 { model.dismiss() } }
                )
            ) {
                NotificationPrimingView(
                    onAllow: { Task { await model.allow() } },
                    onNotNow: { model.dismiss() }
                )
            }
            .task {
                await model.evaluate()
            }
    }
}

public extension View {
    func notificationPriming(dependencies: OnboardingDependencies) -> some View {
        modifier(NotificationPrimingModifier(dependencies: dependencies))
    }
}
