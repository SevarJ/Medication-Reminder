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
import WidgetSnapshot

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
    @State private var onboardingProgress: OnboardingProgress?
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
                if let link = DoseLink(url: url) {
                    router.open(medicationId: link.medicationId, scheduledDate: link.scheduledDate)
                }
                else if TodayLink.matches(url) {
                    selectedTab = .today
                }
                else {
                    FirebaseConfigurator.open(url)
                }
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
            afterOnboarding(at: .beforeSignIn) {
                account.makeScreen(.signIn)
                    .id(language)
            }
        case .signedIn:
            afterOnboarding(at: .afterSignIn) {
                MainTabView(
                    dashboard: dashboard,
                    settings: settings,
                    selection: $selectedTab,
                    revision: router.revision + session.revision
                )
                    .id(language)
                    .fullScreenCover(item: $router.doseReminder, onDismiss: router.didClose) { route in
                        dashboard.makeScreen(route)
                    }
            }
        }
    }
    
    /// Shows the onboarding steps still pending at this stage one after another, then the content.
    private func afterOnboarding(at stage: OnboardingStage, @ViewBuilder content: () -> some View) -> some View {
        ZStack {
            if let progress = onboardingProgress, progress.stage == stage {
                if let route = progress.route {
                    onboarding.makeScreen(route) {
                        Task { await showNextOnboardingStep(at: stage) }
                    }
                    .id(route)
                    .transition(.opacity)
                }
                else {
                    content()
                        .transition(.opacity)
                }
            }
            else {
                Color.theme.background
                    .ignoresSafeArea()
            }
        }
        .task {
            await showNextOnboardingStep(at: stage)
        }
    }
    
    private func showNextOnboardingStep(at stage: OnboardingStage) async {
        let route = await onboarding.pendingRoute(at: stage)
        
        withAnimation {
            onboardingProgress = OnboardingProgress(stage: stage, route: route)
        }
    }
    
    /// Picks up changes made on another device while this one was in the background.
    private func refreshAfterBackground() {
        switch scenePhase {
        case .background:
            wasInBackground = true
            
            Task { await session.publishUpcomingDoses() }
        case .active where wasInBackground:
            wasInBackground = false
            
            Task { await session.refresh() }
        default:
            break
        }
    }
}

private struct OnboardingProgress: Equatable {
    let stage: OnboardingStage
    let route: OnboardingRoute?
}

private enum AppTab: Hashable {
    case today
    case medications
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
            
            settings.makeScreen(.settings)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(AppTab.settings)
        }
        .tint(Color.theme.accent)
    }
}
