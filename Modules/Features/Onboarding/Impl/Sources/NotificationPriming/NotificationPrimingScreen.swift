//
//  NotificationPrimingScreen.swift
//  OnboardingImpl
//
//  Created by Sevar Jafarli on 26.09.26.
//

import SwiftUI

struct NotificationPrimingScreen: View {
    @State private var model: NotificationPrimingModel

    @Environment(\.dismiss) private var dismiss

    init(model: NotificationPrimingModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        NotificationPrimingView(
            onAllow: {
                Task {
                    await model.allow()
                    dismiss()
                }
            },
            onNotNow: {
                model.dismiss()
                dismiss()
            }
        )
        .onDisappear {
            model.dismiss()
        }
    }
}
