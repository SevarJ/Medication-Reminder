//
//  ScheduledDoseTests.swift
//  Domain
//
//  Created by Sevar Jafarli on 17.09.26.
//

import DomainTesting
import Foundation
import Testing
@testable import Domain

struct ScheduledDoseTests {
    @Test("No dose log, expected missed")
    func noDoseLogMissedMedication() async throws {
        let medication = try makeMedication()
        
        let currentDate = Date.now
        let scheduledDate = currentDate.addingTimeInterval(-3600)
        
        let dose = ScheduledDose(
            medication: medication,
            scheduledDate: scheduledDate
        )
        
        let doseState = dose.state(at: currentDate)
        #expect(doseState == .missed)
    }
    
    @Test("No dose log, pending medication")
    func noDoseLogPendingMedication() async throws {
        let medication = try makeMedication()
        
        let currentDate = Date.now
        let scheduledDate = currentDate.addingTimeInterval(3600)
        
        let dose = ScheduledDose(
            medication: medication,
            scheduledDate: scheduledDate
        )
        
        let doseState = dose.state(at: currentDate)
        #expect(doseState == .pending)
    }
    
    @Test("There is a dose log, taken medication")
    func doseLogTakenMedication() async throws {
        let medication = try makeMedication()
        
        let currentDate = Date.now
        let scheduledDate = currentDate.addingTimeInterval(-3600)
        
        let dose = ScheduledDose(
            medication: medication,
            scheduledDate: scheduledDate,
            log: DoseLog(
                medicationId: medication.id,
                scheduledDate: scheduledDate,
                status: .taken,
                recordedAt: scheduledDate
            )
        )
        
        let doseState = dose.state(at: currentDate)
        #expect(doseState == .taken)
    }
    
    @Test("There is a dose log, skipped medication")
    func doseLogSkippedMedication() async throws {
        let medication = try makeMedication()
        
        let currentDate = Date.now
        let scheduledDate = currentDate.addingTimeInterval(-3600)
        
        let dose = ScheduledDose(
            medication: medication,
            scheduledDate: scheduledDate,
            log: DoseLog(
                medicationId: medication.id,
                scheduledDate: scheduledDate,
                status: .skipped,
                recordedAt: scheduledDate
            )
        )
        
        let doseState = dose.state(at: currentDate)
        #expect(doseState == .skipped)
    }
}
