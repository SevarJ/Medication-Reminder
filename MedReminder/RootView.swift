//
//  RootView.swift
//  MedReminder
//
//  Created by Sevar Jafarli on 24.09.26.
//

import DesignSystem
import MedicationFeature
import SwiftUI

struct RootView: View {
    @State private var todayViewModel = AppComposition.makeTodayViewModel()
    @State private var historyViewModel = AppComposition.makeHistoryViewModel()
    @State private var listViewModel = AppComposition.makeListViewModel()
    @State private var primingModel = AppComposition.makeNotificationPrimingModel()
    
    var body: some View {
        TabView {
            TodayView(viewModel: todayViewModel)
                .tabItem {
                    Label("Today", systemImage: "checklist")
                }
            
            HistoryView(viewModel: historyViewModel)
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
            
            MedicationListView(viewModel: listViewModel)
                .tabItem {
                    Label("Medications", systemImage: "pills.fill")
                }
        }
        .tint(Color.theme.accent)
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
    }
}
