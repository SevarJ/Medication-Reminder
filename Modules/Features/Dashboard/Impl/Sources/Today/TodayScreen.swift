//
//  TodayScreen.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 26.09.26.
//

import Dashboard
import SwiftUI

public struct TodayScreen: View {
    @State private var viewModel: TodayViewModel
    private let reloadToken: Int

    public init(dependencies: DashboardDependencies, reloadToken: Int = 0) {
        _viewModel = State(
            initialValue: TodayViewModel(
                loadHistory: dependencies.loadDoseHistory,
                recordDose: dependencies.recordDose,
                saveMedication: dependencies.saveMedication
            )
        )
        self.reloadToken = reloadToken
    }

    public var body: some View {
        TodayView(viewModel: viewModel)
            .onChange(of: reloadToken) {
                Task { await viewModel.start() }
            }
    }
}
