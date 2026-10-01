//
//  ClearLocalDataUseCaseTests.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.10.26.
//

import DomainTesting
import Foundation
import Testing
@testable import Domain

struct ClearLocalDataUseCaseTests {
    private func makeLog() -> DoseLog {
        DoseLog(medicationId: UUID(), scheduledDate: .now, status: .taken, recordedAt: .now)
    }
    
    @Test func removesRemindersCacheAndOfflineCopy() async throws {
        let medicationCache = MockMedicationRepository(medications: [try makeMedication()])
        let doseLogCache = MockDoseLogRepository(logs: [makeLog()])
        let remoteOffline = MockRemoteOfflineStore()
        let scheduler = MockReminderScheduler()
        let sut = ClearLocalDataUseCase(
            medicationCache: medicationCache,
            doseLogCache: doseLogCache,
            remoteOffline: remoteOffline,
            scheduler: scheduler
        )
        
        try await sut.execute()
        
        #expect(await medicationCache.medications.isEmpty)
        #expect(await doseLogCache.logs.isEmpty)
        #expect(await remoteOffline.clearCount == 1)
        #expect(await scheduler.cancelAllCount == 1)
    }
    
    @Test func failedStepDoesNotStopTheRest() async throws {
        let doseLogCache = MockDoseLogRepository(logs: [makeLog()])
        let remoteOffline = MockRemoteOfflineStore()
        let sut = ClearLocalDataUseCase(
            medicationCache: MockMedicationRepository(medications: [try makeMedication()], replaceAllFails: true),
            doseLogCache: doseLogCache,
            remoteOffline: remoteOffline,
            scheduler: MockReminderScheduler()
        )
        
        await #expect(throws: PersistenceFailure.self) {
            try await sut.execute()
        }
        
        #expect(await doseLogCache.logs.isEmpty)
        #expect(await remoteOffline.clearCount == 1)
    }
}
