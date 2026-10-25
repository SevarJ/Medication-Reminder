//
//  IntroductionView.swift
//  OnboardingImpl
//
//  Created by Sevar Jafarli on 25.10.26.
//

import DesignSystem
import SwiftUI

struct IntroductionView: View {
    private let onFinish: () -> Void

    @State private var page: IntroductionPage = .reminders

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    var body: some View {
        VStack(spacing: Spacing.xl) {
            TabView(selection: $page) {
                ForEach(IntroductionPage.allCases) { page in
                    IntroductionPageView(page: page)
                        .tag(page)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            PageDots(selection: page)

            Button(page.next == nil ? L10n.Introduction.start : L10n.Introduction.next) {
                if let next = page.next {
                    withAnimation { page = next }
                }
                else {
                    onFinish()
                }
            }
            .buttonStyle(.primaryAction)
            .padding(.horizontal, Spacing.xxl)
        }
        .padding(.bottom, Spacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.background)
    }
}

private struct IntroductionPageView: View {
    let page: IntroductionPage

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xxl) {
                HeroGlyph(systemName: page.systemImage)

                VStack(spacing: Spacing.md) {
                    Text(page.title)
                        .font(Font.theme.screenTitle)
                        .foregroundStyle(Color.theme.textPrimary)

                    Text(page.message)
                        .font(.system(.title3))
                        .foregroundStyle(Color.theme.textSecondary)
                }
                .multilineTextAlignment(.center)
                .accessibilityElement(children: .combine)
            }
            .padding(Spacing.xxl)
            .frame(maxWidth: .infinity)
        }
        .defaultScrollAnchor(.center)
        .scrollBounceBehavior(.basedOnSize)
    }
}

private struct PageDots: View {
    let selection: IntroductionPage

    var body: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(IntroductionPage.allCases) { page in
                Capsule()
                    .fill(page == selection ? Color.theme.accent : Color.theme.separator)
                    .frame(width: page == selection ? 24 : 8, height: 8)
            }
        }
        .animation(.spring(duration: 0.3), value: selection)
        .accessibilityHidden(true)
    }
}
