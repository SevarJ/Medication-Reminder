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
}
