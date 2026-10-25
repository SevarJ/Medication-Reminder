//
//  MockReminderScheduler.swift
//  DomainTesting
//
//  Created by Sevar Jafarli on 01.08.26.
//

import Domain
import Foundation

public actor MockReminderScheduler: ReminderScheduling {
    public private(set) var scheduledIds: [UUID] = []
    public private(set) var cancelledIds: [UUID] = []
    public private(set) var snoozedIds: [UUID] = []
    public private(set) var snoozedDoseDates: [Date] = []
    public private(set) var cancelAllCount = 0
    public private(set) var lowStockAlerts: [Medication] = []
    public private(set) var followUps: [[ScheduledDose]] = []

    private let failsWithAuthorizationDenied: Bool

    public init(failsWithAuthorizationDenied: Bool = false) {
        self.failsWithAuthorizationDenied = failsWithAuthorizationDenied
    }

    public func schedule(for medication: Medication) async throws {
        if failsWithAuthorizationDenied {
            throw ReminderError.authorizationDenied
        }

        scheduledIds.append(medication.id)
    }

    public func cancel(for medicationId: UUID) async throws {
        cancelledIds.append(medicationId)
    }

    public func cancelAll() async throws {
        cancelAllCount += 1
    }

    public func snooze(_ medication: Medication, scheduledDate: Date, until date: Date) async throws {
        snoozedIds.append(medication.id)
        snoozedDoseDates.append(scheduledDate)
    }

    public func scheduleLowStockAlert(for medication: Medication) async throws {
        if failsWithAuthorizationDenied {
            throw ReminderError.authorizationDenied
        }

        lowStockAlerts.append(medication)
    }

    public func scheduleFollowUps(for doses: [ScheduledDose]) async throws {
        if failsWithAuthorizationDenied {
            throw ReminderError.authorizationDenied
        }

        followUps.append(doses)
    }
}
