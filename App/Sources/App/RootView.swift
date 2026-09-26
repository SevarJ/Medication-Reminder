//
//  RootView.swift
//  MedReminder
//
//  Created by Sevar Jafarli on 24.09.26.
//

import AppLocalization
import AppPreferences
import DashboardImpl
import DesignSystem
import Domain
import NotificationsKit
import OnboardingImpl
import SettingsImpl
import SwiftUI

struct RootView: View {
    @Bindable var router: ReminderRouter
    
    @AppStorage(AppLanguage.storageKey) private var language: AppLanguage = .system
    @AppStorage(PreferenceKey.appearance) private var appearance: AppAppearance = .system
    @AppStorage(PreferenceKey.snoozeMinutes) private var snoozeDuration: SnoozeDuration = .default
    @State private var selectedTab: AppTab = .today
    @State private var isShowingNotificationPriming = false
    
    var body: some View {
        MainTabView(selection: $selectedTab, revision: router.revision)
            .id(language)
            .environment(\.locale, language.locale)
            .preferredColorScheme(appearance.colorScheme)
            .sheet(isPresented: $isShowingNotificationPriming) {
                OnboardingModule.makeNotificationPrimingView {
                    isShowingNotificationPriming = false
                }
            }
            .fullScreenCover(item: $router.doseReminder, onDismiss: router.didClose) { route in
                DashboardModule.makeDoseReminderView(
                    medicationId: route.medicationId,
                    scheduledDate: route.scheduledDate,
                    onClose: router.close
                )
            }
            .task {
                isShowingNotificationPriming = await OnboardingModule.shouldShowNotificationPriming()
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
    
    var body: some View {
        TabView(selection: $selection) {
            DashboardModule.makeTodayView(reloadToken: revision)
                .tabItem {
                    Label("Today", systemImage: "checklist")
                }
                .tag(AppTab.today)
            
            DashboardModule.makeMedicationsView()
                .tabItem {
                    Label("Medications", systemImage: "pills.fill")
                }
                .tag(AppTab.medications)
            
            SettingsModule.makeSettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(AppTab.settings)
        }
        .tint(Color.theme.accent)
    }
}
