//
//  SignInView.swift
//  AccountImpl
//
//  Created by Sevar Jafarli on 01.10.26.
//

import AppLocalization
import DesignSystem
import SwiftUI

struct SignInView: View {
    @State private var viewModel: SignInViewModel

    init(viewModel: SignInViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            HeroGlyph(systemName: "pills.fill")

            VStack(spacing: Spacing.md) {
                Text(L10n.SignIn.title)
                    .font(Font.theme.screenTitle)
                    .foregroundStyle(Color.theme.textPrimary)
                    .multilineTextAlignment(.center)

                Text(L10n.SignIn.message)
                    .font(.system(.body))
                    .foregroundStyle(Color.theme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Button {
                Task { await viewModel.signIn() }
            } label: {
                ZStack {
                    Text(L10n.SignIn.continueWithGoogle)
                        .opacity(viewModel.isSigningIn ? 0 : 1)

                    if viewModel.isSigningIn {
                        ProgressView()
                            .tint(Color.theme.onHero)
                    }
                }
            }
            .buttonStyle(.primaryAction)
            .disabled(viewModel.isSigningIn)
        }
        .padding(Spacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.background)
        .alert(
            CommonText.errorTitle,
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button(CommonText.ok, role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
