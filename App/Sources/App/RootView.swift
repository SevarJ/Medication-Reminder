//
//  RootView.swift
//  Medora
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Account
import AppLocalization
import AppPreferences
import Dashboard
import DesignSystem
import Domain
import FirebaseKit
import NotificationsKit
import Onboarding
import Settings
import SwiftUI

struct RootView<Account: AccountModule, Dashboard: DashboardModule, Settings: SettingsModule, Onboarding: OnboardingModule>: View {
    @Bindable var router: ReminderRouter
    let session: SessionStore
    let account: Account
    let dashboard: Dashboard
    let settings: Settings
    let onboarding: Onboarding
    
    @AppStorage(AppLanguage.storageKey) private var language: AppLanguage = .system
    @AppStorage(PreferenceKey.appearance) private var appearance: AppAppearance = .system
    @AppStorage(PreferenceKey.snoozeMinutes) private var snoozeDuration: SnoozeDuration = .default
    @State private var selectedTab: AppTab = .today
    @State private var onboardingRoute: OnboardingRoute?
    @State private var wasInBackground = false
    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        content
            .environment(\.locale, language.locale)
            .preferredColorScheme(appearance.colorScheme)
            .task {
                await session.observe()
            }
            .onOpenURL { url in
                FirebaseConfigurator.open(url)
            }
            .onChange(of: session.state) {
                if session.state == .signedOut {
                    selectedTab = .today
                }
            }
            .onChange(of: scenePhase) {
                refreshAfterBackground()
            }
            .onChange(of: language) {
                ReminderCategory.register(snoozeMinutes: snoozeDuration.minutes)
            }
            .onChange(of: snoozeDuration) {
                ReminderCategory.register(snoozeMinutes: snoozeDuration.minutes)
            }
    }
    
    @ViewBuilder
    private var content: some View {
        switch session.state {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.theme.background)
        case .signedOut:
            account.makeScreen(.signIn)
                .id(language)
        case .signedIn:
            MainTabView(
                dashboard: dashboard,
                settings: settings,
                selection: $selectedTab,
                revision: router.revision + session.revision
            )
                .id(language)
                .sheet(item: $onboardingRoute) { route in
                    onboarding.makeScreen(route)
                }
                .fullScreenCover(item: $router.doseReminder, onDismiss: router.didClose) { route in
                    dashboard.makeScreen(route)
                }
                .task {
                    onboardingRoute = await onboarding.pendingRoute()
                }
        }
    }
    
    /// Picks up changes made on another device while this one was in the background.
    private func refreshAfterBackground() {
        switch scenePhase {
        case .background:
            wasInBackground = true
        case .active where wasInBackground:
            wasInBackground = false
            
            Task { await session.refresh() }
        default:
            break
        }
    }
}

private enum AppTab: Hashable {
    case today
    case medications
    case history
    case settings
}

private struct MainTabView<Dashboard: DashboardModule, Settings: SettingsModule>: View {
    let dashboard: Dashboard
    let settings: Settings
    @Binding var selection: AppTab
    let revision: Int
    
    var body: some View {
        TabView(selection: $selection) {
            dashboard.makeScreen(.today(reloadToken: revision))
                .tabItem {
                    Label("Today", systemImage: "checklist")
                }
                .tag(AppTab.today)
            
            dashboard.makeScreen(.medications(reloadToken: revision))
                .tabItem {
                    Label("Medications", systemImage: "pills.fill")
                }
                .tag(AppTab.medications)
            
            dashboard.makeScreen(.history(reloadToken: revision))
                .tabItem {
                    Label("History", systemImage: "calendar")
                }
                .tag(AppTab.history)
            
            settings.makeScreen(.settings)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(AppTab.settings)
        }
        .tint(Color.theme.accent)
    }
}
