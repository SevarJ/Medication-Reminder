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

    public func snooze(_ medication: Medication, until date: Date) async throws {
        snoozedIds.append(medication.id)
    }
}
