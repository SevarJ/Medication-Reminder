//
//  DoseReminderScreen.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 26.09.26.
//

import Dashboard
import Foundation
import SwiftUI

public struct DoseReminderScreen: View {
    @State private var viewModel: DoseReminderViewModel
    private let onClose: () -> Void

    public init(
        request: DoseReminderRequest,
        dependencies: DashboardDependencies,
        snoozeDelay: TimeInterval,
        onClose: @escaping () -> Void
    ) {
        _viewModel = State(
            initialValue: DoseReminderViewModel(
                medicationId: request.medicationId,
                scheduledDate: request.scheduledDate,
                loadDose: dependencies.loadScheduledDose,
                recordDose: dependencies.recordDose,
                snoozeReminder: dependencies.snoozeReminder,
                snoozeDelay: snoozeDelay
            )
        )
        self.onClose = onClose
    }

    public var body: some View {
        DoseReminderView(viewModel: viewModel, onClose: onClose)
    }
}
