//
//  ReminderScheduling.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.08.26.
//

import Foundation

public protocol ReminderScheduling: Sendable {
    func schedule(for medication: Medication) async throws
    func cancel(for medicationId: UUID) async throws
    /// Removes every reminder, both the ones still to come and the ones already on screen.
    func cancelAll() async throws
    func snooze(_ medication: Medication, until date: Date) async throws
}
