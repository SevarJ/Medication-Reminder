//
//  MockReminderScheduler.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.08.26.
//

@testable import Domain
import Foundation

actor MockReminderScheduler: ReminderScheduling {
    private(set) var scheduledIds: [UUID] = []
    private(set) var cancelledIds: [UUID] = []
    private(set) var snoozedIds: [UUID] = []
    
    func schedule(for medication: Medication) async throws {
        scheduledIds.append(medication.id)
    }
    
    func cancel(for medicationId: UUID) async throws {
        cancelledIds.append(medicationId)
    }
    
    func snooze(_ medication: Medication, until date: Date) async throws {
        snoozedIds.append(medication.id)
    }
}
