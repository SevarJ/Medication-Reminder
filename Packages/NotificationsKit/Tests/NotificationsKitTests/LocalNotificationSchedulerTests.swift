//
//  LocalNotificationSchedulerTests.swift
//  NotificationsKit
//
//  Created by Sevar Jafarli on 12.09.26.
//

import Domain
import Foundation
import Testing
@testable import NotificationsKit

struct LocalNotificationSchedulerTests {
    @Test func schedulesOneReminderPerTime() async throws {
        let center = MockUserNotificationCenter()
        let sut = LocalNotificationScheduler(center: center)
        let medication = try makeMedication(times: [(9, 0), (21, 30)])
        
        try await sut.schedule(for: medication)
        
        let added = await center.added
        
        #expect(added.count == 2)
        #expect(added.map { $0.hour } == [9, 21])
        #expect(added.map { $0.minute } == [0, 30])
        #expect(added.allSatisfy { $0.title == medication.name })
        #expect(added.allSatisfy { $0.medicationId == medication.id })
    }
    
    @Test func reschedulingReplacesPreviousReminders() async throws {
        let center = MockUserNotificationCenter()
        let sut = LocalNotificationScheduler(center: center)
        let medication = try makeMedication(times: [(9, 0)])
        
        try await sut.schedule(for: medication)
        try await sut.schedule(for: medication)
        
        #expect(await center.added.count == 1)
    }
    
    @Test func cancelRemovesOnlyMatchingMedication() async throws {
        let center = MockUserNotificationCenter()
        let sut = LocalNotificationScheduler(center: center)
        let first = try makeMedication(times: [(9, 0)])
        let second = try makeMedication(times: [(12, 0)])
        
        try await sut.schedule(for: first)
        try await sut.schedule(for: second)
        try await sut.cancel(for: first.id)
        
        let remaining = await center.added
        
        #expect(remaining.count == 1)
        #expect(remaining.first?.medicationId == second.id)
    }
    
    @Test func schedulingThrowsWhenAuthorizationDenied() async throws {
        let center = MockUserNotificationCenter(status: .denied)
        let sut = LocalNotificationScheduler(center: center)
        
        await #expect(throws: ReminderError.authorizationDenied) {
            try await sut.schedule(for: try makeMedication())
        }
        
        #expect(await center.added.isEmpty)
    }
    
    @Test func identifierIsNamespacedByMedication() async throws {
        let medicationId = UUID()
        let timeId = UUID()
        let identifier = LocalNotificationScheduler.identifier(
            medicationId: medicationId,
            timeId: timeId
        )
        
        #expect(identifier.hasPrefix(LocalNotificationScheduler.identifierPrefix(medicationId: medicationId)))
        #expect(identifier.hasSuffix(timeId.uuidString))
    }
}
