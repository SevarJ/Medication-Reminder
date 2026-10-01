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

            Image(systemName: "pills.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.theme.accent)
                .padding(Spacing.xxl)
                .background(Color.theme.accentTint, in: Circle())

            VStack(spacing: Spacing.md) {
                Text(L10n.SignIn.title)
                    .font(Font.theme.screenTitle)
                    .foregroundStyle(Color.theme.textPrimary)
                    .multilineTextAlignment(.center)

                Text(L10n.SignIn.message)
                    .font(Font.theme.rowSubtitle)
                    .foregroundStyle(Color.theme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Button {
                Task { await viewModel.signIn() }
            } label: {
                ZStack {
                    Text(L10n.SignIn.continueWithGoogle)
                        .font(Font.theme.rowTitle)
                        .opacity(viewModel.isSigningIn ? 0 : 1)

                    if viewModel.isSigningIn {
                        ProgressView()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.theme.accent)
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
