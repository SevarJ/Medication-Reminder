//
//  RootView.swift
//  MedReminder
//
//  Created by Sevar Jafarli on 24.09.26.
//

import AppLocalization
import AppPreferences
import Dashboard
import DashboardImpl
import DesignSystem
import Domain
import NotificationsKit
import Onboarding
import OnboardingImpl
import Settings
import SettingsImpl
import SwiftUI

struct RootView: View {
    let container: AppContainer
    @Bindable var router: ReminderRouter
    
    @AppStorage(AppLanguage.storageKey) private var language: AppLanguage = .system
    @AppStorage(PreferenceKey.appearance) private var appearance: AppAppearance = .system
    @AppStorage(PreferenceKey.snoozeMinutes) private var snoozeDuration: SnoozeDuration = .default
    @State private var selectedTab: AppTab = .today
    
    var body: some View {
        MainTabView(
            selection: $selectedTab,
            revision: router.revision,
            dashboard: container.dashboard,
            settings: container.settings
        )
            .id(language)
            .environment(\.locale, language.locale)
            .preferredColorScheme(appearance.colorScheme)
            .notificationPriming(dependencies: container.onboarding)
            .fullScreenCover(item: $router.doseReminder, onDismiss: router.didClose) { request in
                DoseReminderScreen(
                    request: request,
                    dependencies: container.dashboard,
                    snoozeDelay: snoozeDuration.interval,
                    onClose: router.close
                )
            }
            .onChange(of: language) {
                ReminderCategory.register(snoozeMinutes: snoozeDuration.minutes)
            }
            .onChange(of: snoozeDuration) {
                ReminderCategory.register(snoozeMinutes: snoozeDuration.minutes)
            }
    }
}

private enum AppTab: Hashable {
    case today
    case medications
    case settings
}

private struct MainTabView: View {
    @Binding var selection: AppTab
    let revision: Int
    let dashboard: DashboardDependencies
    let settings: SettingsDependencies
    
    var body: some View {
        TabView(selection: $selection) {
            TodayScreen(dependencies: dashboard, reloadToken: revision)
                .tabItem {
                    Label("Today", systemImage: "checklist")
                }
                .tag(AppTab.today)
            
            MedicationsScreen(dependencies: dashboard)
                .tabItem {
                    Label("Medications", systemImage: "pills.fill")
                }
                .tag(AppTab.medications)
            
            SettingsScreen(dependencies: settings)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(AppTab.settings)
        }
        .tint(Color.theme.accent)
    }
}
