//
//  NotificationPrimingScreen.swift
//  OnboardingImpl
//
//  Created by Sevar Jafarli on 26.09.26.
//

import SwiftUI

struct NotificationPrimingScreen: View {
    @State private var model: NotificationPrimingModel
    private let onFinish: () -> Void

    init(model: NotificationPrimingModel, onFinish: @escaping () -> Void) {
        _model = State(initialValue: model)
        self.onFinish = onFinish
    }

    var body: some View {
        NotificationPrimingView(
            onAllow: {
                Task {
                    await model.allow()
                    onFinish()
                }
            },
            onNotNow: {
                model.dismiss()
                onFinish()
            }
        )
        .onDisappear {
            model.dismiss()
        }
    }
}
