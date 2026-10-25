//
//  SettingsView.swift
//  SettingsImpl
//
//  Created by Sevar Jafarli on 24.09.26.
//

import AppLocalization
import AppPreferences
import DesignSystem
import Domain
import Paywall
import StoreKit
import SwiftUI
import UIKit

struct SettingsView<Paywall: PaywallModule>: View {
    @State private var viewModel: SettingsViewModel
    @State private var isPaywallPresented = false
    @State private var isManagingSubscription = false
    
    private let paywall: Paywall
    
    @AppStorage(PreferenceKey.appearance) private var appearance: AppAppearance = .system
    @AppStorage(PreferenceKey.snoozeMinutes) private var snoozeDuration: SnoozeDuration = .default
    
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    init(paywall: Paywall, viewModel: SettingsViewModel) {
        self.paywall = paywall
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    accountHeader
                    proSection
                    generalSection
                    notificationsSection
                    aboutSection
                }
                .padding(.vertical, Spacing.lg)
            }
            .background(Color.theme.background)
            .navigationTitle(L10n.Settings.title)
            .navigationBarTitleDisplayMode(.large)
        }
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
        .task {
            await viewModel.start()
        }
        .fullScreenCover(isPresented: $isPaywallPresented) {
            Task { await viewModel.refreshEntitlement() }
        } content: {
            paywall.makeScreen(.settings) {
                isPaywallPresented = false
            }
        }
        .manageSubscriptionsSheet(isPresented: $isManagingSubscription)
        .onChange(of: isManagingSubscription) {
            if !isManagingSubscription {
                Task { await viewModel.refreshEntitlement() }
            }
        }
        .onChange(of: scenePhase) { _, newValue in
            if newValue == .active {
                Task {
                    await viewModel.refreshNotificationAccess()
                }
            }
        }
    }
    
    private var generalSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: L10n.Settings.general)
            
            CardSection {
                pickerRow(
                    title: L10n.Settings.language,
                    systemName: "globe",
                    tint: .blue,
                    selection: languageSelection,
                    options: AppLanguage.allCases,
                    label: \.displayName
                )
                
                RowSeparator(leadingInset: 58)
                
                pickerRow(
                    title: L10n.Settings.appearance,
                    systemName: "circle.lefthalf.filled",
                    tint: .gray,
                    selection: $appearance,
                    options: AppAppearance.allCases,
                    label: \.displayName
                )
            }
        }
    }
    
    private func pickerRow<Option: Hashable & Identifiable>(
        title: String,
        systemName: String,
        tint: Color,
        selection: Binding<Option>,
        options: [Option],
        label: KeyPath<Option, String>
    ) -> some View {
        AdaptiveStack {
            IconTile(
                systemName: systemName,
                foreground: .white,
                background: tint
            )
            
            Text(title)
                .font(Font.theme.rowTitle)
                .foregroundStyle(Color.theme.textPrimary)
            
            Spacer(minLength: 0)
            
            Picker(title, selection: selection) {
                ForEach(options) { option in
                    Text(option[keyPath: label]).tag(option)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .fixedSize(horizontal: !dynamicTypeSize.isAccessibilitySize, vertical: false)
            .tint(Color.theme.textSecondary)
            .frame(maxWidth: dynamicTypeSize.isAccessibilitySize ? .infinity : nil, alignment: .leading)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
        .frame(minHeight: Size.minTarget + Spacing.md)
    }
    
    private var languageSelection: Binding<AppLanguage> {
        Binding(
            get: { viewModel.language },
            set: { language in
                Task { await viewModel.select(language) }
            }
        )
    }
    
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: L10n.Settings.notifications)
            
            CardSection {
                Button(action: performNotificationAction) {
                    AdaptiveStack {
                        IconTile(
                            systemName: "bell.fill",
                            foreground: .white,
                            background: .red
                        )
                        
                        Text(L10n.Settings.reminders)
                            .font(Font.theme.rowTitle)
                            .foregroundStyle(Color.theme.textPrimary)
                        
                        Spacer(minLength: 0)
                        
                        Text(notificationStatus)
                            .font(Font.theme.rowSubtitle)
                            .foregroundStyle(Color.theme.textSecondary)
                        
                        if !dynamicTypeSize.isAccessibilitySize {
                            Image(systemName: "chevron.right")
                                .font(Font.theme.caption)
                                .foregroundStyle(Color.theme.textSecondary)
                        }
                    }
                    .padding(Spacing.lg)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                RowSeparator(leadingInset: 58)
                
                pickerRow(
                    title: L10n.Settings.snooze,
                    systemName: "clock.arrow.circlepath",
                    tint: .orange,
                    selection: $snoozeDuration,
                    options: SnoozeDuration.allCases,
                    label: \.displayName
                )
            }
        }
    }
    
    private var notificationStatus: String {
        switch viewModel.notificationAccess {
        case .authorized: L10n.Settings.notificationsOn
        case .denied: L10n.Settings.notificationsOff
        case .notDetermined: L10n.Settings.notificationsNotSetUp
        case nil: ""
        }
    }
    
    private func performNotificationAction() {
        guard viewModel.notificationAccess != .notDetermined else {
            Task { await viewModel.enableNotifications() }
            return
        }
        
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        
        openURL(url)
    }
    
    @ViewBuilder
    private var accountHeader: some View {
        if let account = viewModel.account {
            CardSection {
                NavigationLink {
                    ProfileView(
                        account: account,
                        isDeletingAccount: viewModel.isDeletingAccount,
                        onSignOut: { Task { await viewModel.signOut() } },
                        onDeleteAccount: { Task { await viewModel.deleteAccount() } }
                    )
                } label: {
                    AdaptiveStack {
                        AccountAvatar(photoURL: account.photoURL, size: 56)
                        
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            if let name = account.displayName {
                                Text(name)
                                    .font(Font.theme.sectionTitle)
                                    .foregroundStyle(Color.theme.textPrimary)
                            }
                            
                            if let email = account.email {
                                Text(email)
                                    .font(Font.theme.rowSubtitle)
                                    .foregroundStyle(Color.theme.textSecondary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                        }
                        
                        Spacer(minLength: 0)
                        
                        if !dynamicTypeSize.isAccessibilitySize {
                            Image(systemName: "chevron.right")
                                .font(.system(.footnote, weight: .semibold))
                                .foregroundStyle(Color.theme.textSecondary.opacity(0.6))
                        }
                    }
                    .padding(Spacing.lg)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    @ViewBuilder
    private var proSection: some View {
        if let entitlement = viewModel.entitlement {
            CardSection {
                Button {
                    if entitlement == .pro {
                        isManagingSubscription = true
                    }
                    else {
                        isPaywallPresented = true
                    }
                } label: {
                    AdaptiveStack {
                        IconTile(
                            systemName: "crown.fill",
                            foreground: .white,
                            background: Color.theme.hero
                        )
                        
                        Text(verbatim: "Medora Pro")
                            .font(Font.theme.rowTitle)
                            .foregroundStyle(Color.theme.textPrimary)
                        
                        Spacer(minLength: 0)
                        
                        if entitlement == .pro {
                            Text(L10n.Settings.proActive)
                                .font(Font.theme.rowSubtitle)
                                .foregroundStyle(Color.theme.successText)
                        }
                        
                        if !dynamicTypeSize.isAccessibilitySize {
                            Image(systemName: "chevron.right")
                                .font(Font.theme.caption)
                                .foregroundStyle(Color.theme.textSecondary)
                        }
                    }
                    .padding(Spacing.lg)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: L10n.Settings.about)
            
            CardSection {
                if let url = viewModel.privacyPolicyURL {
                    Link(destination: url) {
                        AdaptiveStack {
                            IconTile(
                                systemName: "hand.raised.fill",
                                foreground: .white,
                                background: .blue
                            )
                            
                            Text(L10n.Settings.privacyPolicy)
                                .font(Font.theme.rowTitle)
                                .foregroundStyle(Color.theme.textPrimary)
                            
                            Spacer(minLength: 0)
                            
                            if !dynamicTypeSize.isAccessibilitySize {
                                Image(systemName: "arrow.up.right")
                                    .font(Font.theme.caption)
                                    .foregroundStyle(Color.theme.textSecondary)
                            }
                        }
                        .padding(Spacing.lg)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    RowSeparator(leadingInset: 58)
                }
                
                AdaptiveStack {
                    IconTile(
                        systemName: "info.circle.fill",
                        foreground: .white,
                        background: .gray
                    )
                    
                    Text(L10n.Settings.version)
                        .font(Font.theme.rowTitle)
                        .foregroundStyle(Color.theme.textPrimary)
                    
                    Spacer(minLength: 0)
                    
                    Text(viewModel.appVersion)
                        .font(Font.theme.rowSubtitle)
                        .foregroundStyle(Color.theme.textSecondary)
                }
                .padding(Spacing.lg)
            }
        }
    }
}
