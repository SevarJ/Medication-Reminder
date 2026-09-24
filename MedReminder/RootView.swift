//
//  RootView.swift
//  MedReminder
//
//  Created by Sevar Jafarli on 24.09.26.
//

import DesignSystem
import Domain
import MedicationFeature
import NotificationsKit
import SwiftUI

struct RootView: View {
    @AppStorage(AppLanguage.storageKey) private var language: AppLanguage = .system
    @AppStorage(AppAppearance.storageKey) private var appearance: AppAppearance = .system
    @State private var selectedTab: AppTab = .today
    @State private var primingModel = AppComposition.makeNotificationPrimingModel()
    
    var body: some View {
        MainTabView(selection: $selectedTab)
            .id(language)
            .environment(\.locale, language.locale)
            .preferredColorScheme(appearance.colorScheme)
            .sheet(
                isPresented: Binding(
                    get: { primingModel.isPresented },
                    set: { if !$0 { primingModel.dismiss() } }
                )
            ) {
                NotificationPrimingView(
                    onAllow: { Task { await primingModel.allow() } },
                    onNotNow: { primingModel.dismiss() }
                )
            }
            .task {
                await primingModel.evaluate()
            }
            .onChange(of: language) {
                ReminderCategory.register()
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
    
    @State private var todayViewModel = AppComposition.makeTodayViewModel()
    @State private var listViewModel = AppComposition.makeListViewModel()
    @State private var settingsViewModel = AppComposition.makeSettingsViewModel()
    
    var body: some View {
        TabView(selection: $selection) {
            TodayView(viewModel: todayViewModel)
                .tabItem {
                    Label("Today", systemImage: "checklist")
                }
                .tag(AppTab.today)
            
            MedicationListView(viewModel: listViewModel)
                .tabItem {
                    Label("Medications", systemImage: "pills.fill")
                }
                .tag(AppTab.medications)
            
            SettingsView(viewModel: settingsViewModel)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(AppTab.settings)
        }
        .tint(Color.theme.accent)
    }
}
