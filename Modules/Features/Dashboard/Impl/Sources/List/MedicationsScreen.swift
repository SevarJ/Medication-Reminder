//
//  MedicationsScreen.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 26.09.26.
//

import Dashboard
import SwiftUI

public struct MedicationsScreen: View {
    @State private var viewModel: MedicationListViewModel

    public init(dependencies: DashboardDependencies) {
        _viewModel = State(
            initialValue: MedicationListViewModel(
                repository: dependencies.medications,
                saveMedication: dependencies.saveMedication,
                deleteMedication: dependencies.deleteMedication,
                toggleMedicationActive: dependencies.toggleMedicationActive,
                syncReminder: dependencies.syncReminder,
                authorizer: dependencies.authorizer
            )
        )
    }

    public var body: some View {
        MedicationListView(viewModel: viewModel)
    }
}
