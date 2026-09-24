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
    @State private var listViewModel = AppComposition.makeListViewModel()
    
    var body: some View {
        TabView {
            TodayView(viewModel: todayViewModel)
                .tabItem {
                    Label("Today", systemImage: "checklist")
                }
            
            MedicationListView(viewModel: listViewModel)
                .tabItem {
                    Label("Medications", systemImage: "pills.fill")
                }
        }
        .tint(Color.theme.accent)
    }
}
