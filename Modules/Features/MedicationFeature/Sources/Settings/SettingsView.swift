//
//  SettingsView.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 24.09.26.
//

import AppLocalization
import AppPreferences
import DesignSystem
import Domain
import SwiftUI
import UIKit

public struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    
    @AppStorage(PreferenceKey.appearance) private var appearance: AppAppearance = .system
    @AppStorage(PreferenceKey.snoozeMinutes) private var snoozeDuration: SnoozeDuration = .default
    
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    
    public init(viewModel: SettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    generalSection
                    notificationsSection
                    aboutSection
                }
                .padding(.vertical, Spacing.lg)
            }
            .background(Color.theme.background)
            .navigationTitle(L10n.Settings.title)
            .navigationBarTitleDisplayMode(.inline)
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
                    selection: languageSelection,
                    options: AppLanguage.allCases,
                    label: \.displayName
                )
                
                RowSeparator(leadingInset: 58)
                
                pickerRow(
                    title: L10n.Settings.appearance,
                    systemName: "circle.lefthalf.filled",
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
        selection: Binding<Option>,
        options: [Option],
        label: KeyPath<Option, String>
    ) -> some View {
        HStack(spacing: Spacing.md) {
            IconTile(
                systemName: systemName,
                foreground: Color.theme.accent,
                background: Color.theme.accentTint
            )
            
            Text(title)
                .font(Font.theme.rowTitle)
                .foregroundStyle(Color.theme.textPrimary)
            
            Spacer(minLength: Spacing.sm)
            
            Picker(title, selection: selection) {
                ForEach(options) { option in
                    Text(option[keyPath: label]).tag(option)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .fixedSize()
            .tint(Color.theme.textSecondary)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
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
                    HStack(spacing: Spacing.md) {
                        IconTile(
                            systemName: "bell.fill",
                            foreground: Color.theme.accent,
                            background: Color.theme.accentTint
                        )
                        
                        Text(L10n.Settings.reminders)
                            .font(Font.theme.rowTitle)
                            .foregroundStyle(Color.theme.textPrimary)
                        
                        Spacer(minLength: Spacing.sm)
                        
                        Text(notificationStatus)
                            .font(Font.theme.rowSubtitle)
                            .foregroundStyle(Color.theme.textSecondary)
                        
                        Image(systemName: "chevron.right")
                            .font(Font.theme.caption)
                            .foregroundStyle(Color.theme.textSecondary)
                    }
                    .padding(Spacing.lg)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                RowSeparator(leadingInset: 58)
                
                pickerRow(
                    title: L10n.Settings.snooze,
                    systemName: "clock.arrow.circlepath",
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
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: L10n.Settings.about)
            
            CardSection {
                HStack(spacing: Spacing.md) {
                    IconTile(
                        systemName: "info.circle.fill",
                        foreground: Color.theme.accent,
                        background: Color.theme.accentTint
                    )
                    
                    Text(L10n.Settings.version)
                        .font(Font.theme.rowTitle)
                        .foregroundStyle(Color.theme.textPrimary)
                    
                    Spacer(minLength: Spacing.sm)
                    
                    Text(viewModel.appVersion)
                        .font(Font.theme.rowSubtitle)
                        .foregroundStyle(Color.theme.textSecondary)
                }
                .padding(Spacing.lg)
            }
        }
    }
}
