//
//  ReminderNotificationCoordinator.swift
//  MedReminder
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Domain
import NotificationsKit
import UserNotifications

final class ReminderNotificationCoordinator: NSObject, UNUserNotificationCenterDelegate {
    private let recordDose: RecordDoseForMedicationUseCase
    private let snoozeReminder: SnoozeReminderUseCase
    private let router: ReminderRouter
    
    init(
        recordDose: RecordDoseForMedicationUseCase,
        snoozeReminder: SnoozeReminderUseCase,
        router: ReminderRouter
    ) {
        self.recordDose = recordDose
        self.snoozeReminder = snoozeReminder
        self.router = router
    }
    
    func start(on center: UNUserNotificationCenter = .current()) {
        center.delegate = self
        
        ReminderCategory.register(on: center)
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .list]
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        guard let reminder = ReminderResponseParser.parse(response) else { return }
        
        switch reminder.action {
        case .taken:
            await record(reminder, as: .taken)
        case .skipped:
            await record(reminder, as: .skipped)
        case .snooze:
            try? await snoozeReminder.execute(medicationId: reminder.medicationId)
        case .opened:
            await router.open(medicationId: reminder.medicationId, scheduledDate: reminder.scheduledDate)
        }
    }
    
    private func record(_ reminder: ReminderResponse, as status: DoseStatus) async {
        _ = try? await recordDose.execute(
            medicationId: reminder.medicationId,
            scheduledDate: reminder.scheduledDate,
            status: status
        )
    }
}
