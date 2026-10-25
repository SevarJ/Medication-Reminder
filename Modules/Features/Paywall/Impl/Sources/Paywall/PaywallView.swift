//
//  PaywallView.swift
//  PaywallImpl
//
//  Created by Sevar Jafarli on 25.10.26.
//

import AppLocalization
import DesignSystem
import Domain
import StoreKit
import SwiftUI

struct PaywallView: View {
    @State private var viewModel: PaywallViewModel

    private let onFinish: () -> Void

    init(viewModel: PaywallViewModel, onFinish: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onFinish = onFinish
    }

    var body: some View {
        SubscriptionStoreView(productIDs: ProSubscription.productIDs) {
            PaywallHeader()
        }
        .subscriptionStoreControlStyle(.picker)
        .subscriptionStoreButtonLabel(.multiline)
        .storeButton(.hidden, for: .cancellation, .restorePurchases)
        .storeButton(.visible, for: .policies)
        .subscriptionStorePolicyDestination(url: LegalLinks.termsOfUse, for: .termsOfService)
        .subscriptionStorePolicyDestination(url: LegalLinks.privacyPolicy, for: .privacyPolicy)
        .onInAppPurchaseCompletion { _, result in
            await viewModel.finishPurchase(await StorePurchase.outcome(of: result))
        }
        .containerBackground(Color.theme.background, for: .subscriptionStoreFullHeight)
        .tint(Color.theme.hero)
        .safeAreaInset(edge: .top) {
            topBar
        }
        .background(Color.theme.background)
        .task {
            await viewModel.appear()
        }
        .onChange(of: viewModel.isFinished) {
            if viewModel.isFinished {
                onFinish()
            }
        }
        .alert(
            noticeTitle,
            isPresented: Binding(
                get: { viewModel.notice != nil },
                set: { if !$0 { viewModel.notice = nil } }
            )
        ) {
            Button(CommonText.ok, role: .cancel) {}
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                viewModel.close()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(.body, weight: .semibold))
                    .foregroundStyle(Color.theme.textSecondary)
                    .frame(width: Size.minTarget, height: Size.minTarget)
                    .background(Color.theme.fill, in: Circle())
            }
            .accessibilityLabel(L10n.close)

            Spacer()

            Button {
                Task { await viewModel.restore() }
            } label: {
                ZStack {
                    Text(L10n.restore)
                        .opacity(viewModel.isRestoring ? 0 : 1)

                    if viewModel.isRestoring {
                        ProgressView()
                    }
                }
                .font(.system(.headline))
                .foregroundStyle(Color.theme.accentText)
                .frame(minHeight: Size.minTarget)
            }
            .disabled(viewModel.isRestoring)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.sm)
    }

    private var noticeTitle: String {
        switch viewModel.notice {
        case .pending: L10n.pending
        case .nothingToRestore: L10n.nothingToRestore
        case .failed, nil: CommonText.errorTitle
        }
    }
}

private struct PaywallHeader: View {
    var body: some View {
        VStack(spacing: Spacing.xl) {
            HeroGlyph(systemName: "crown.fill")

            VStack(spacing: Spacing.md) {
                Text(verbatim: "Medora Pro")
                    .font(Font.theme.screenTitle)
                    .foregroundStyle(Color.theme.textPrimary)

                Text(L10n.message)
                    .font(.system(.title3))
                    .foregroundStyle(Color.theme.textSecondary)
            }
            .multilineTextAlignment(.center)
            .accessibilityElement(children: .combine)
        }
        .padding(.horizontal, Spacing.xxl)
        .padding(.vertical, Spacing.xl)
    }
}
