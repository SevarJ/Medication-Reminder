//
//  DoseAssemblerTests.swift
//  Domain
//
//  Created by Sevar Jafarli on 17.09.26.
//

import DomainTesting
import Foundation
import Testing
@testable import Domain

struct DoseAssemblerTests {
    private let calendar = Calendar(identifier: .gregorian)
    
    private func date(day: Int, hour: Int, minute: Int) throws -> Date {
        try #require(
            calendar.date(from: DateComponents(year: 2026, month: 9, day: day, hour: hour, minute: minute))
        )
    }
    
    private func doses(
        for medications: [Medication],
        logs: [DoseLog] = []
    ) throws -> [ScheduledDose] {
        DoseAssembler.doses(
            for: medications,
            on: try date(day: 16, hour: 12, minute: 0),
            logs: logs,
            calendar: calendar
        )
    }
    
    @Test func excludesMedicationsNotScheduledThatDay() throws {
        let medication = try makeMedication(
            recurrence: .daysOfWeek([.monday]),
            startDate: try date(day: 1, hour: 0, minute: 0)
        )
        
        #expect(try doses(for: [medication]).isEmpty)
    }
    
    @Test func attachesLogToMatchingDose() throws {
        let medication = try makeMedication(
            times: [(9, 0), (21, 0)],
            startDate: try date(day: 1, hour: 0, minute: 0)
        )
        let log = DoseLog(
            medicationId: medication.id,
            scheduledDate: try date(day: 16, hour: 9, minute: 0),
            status: .taken,
            recordedAt: try date(day: 16, hour: 9, minute: 5)
        )
        
        let doses = try doses(for: [medication], logs: [log])
        
        #expect(doses.count == 2)
        #expect(doses[0].log == log)
        #expect(doses[1].log == nil)
    }
    
    @Test func sortsDosesByTime() throws {
        let evening = try makeMedication(
            name: "Magnesium",
            times: [(21, 0)],
            startDate: try date(day: 1, hour: 0, minute: 0)
        )
        let morning = try makeMedication(
            name: "Vitamin D",
            times: [(9, 0)],
            startDate: try date(day: 1, hour: 0, minute: 0)
        )
        
        #expect(try doses(for: [evening, morning]).map { $0.medication.name } == ["Vitamin D", "Magnesium"])
    }
}
