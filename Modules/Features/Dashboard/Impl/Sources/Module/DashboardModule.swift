//
//  DashboardModule.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 26.09.26.
//

import Foundation
import SwiftUI

public enum DashboardModule {
    @MainActor
    public static func makeTodayView(reloadToken: Int) -> some View {
        DashboardModuleImpl().makeTodayView(reloadToken: reloadToken)
    }

    @MainActor
    public static func makeMedicationsView() -> some View {
        DashboardModuleImpl().makeMedicationsView()
    }

    @MainActor
    public static func makeDoseReminderView(
        medicationId: UUID,
        scheduledDate: Date,
        onClose: @escaping () -> Void
    ) -> some View {
        DashboardModuleImpl().makeDoseReminderView(
            medicationId: medicationId,
            scheduledDate: scheduledDate,
            onClose: onClose
        )
    }
}
