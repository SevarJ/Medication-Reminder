//
//  SyncReminderUseCaseTests.swift
//  Domain
//
//  Created by Sevar Jafarli on 12.09.26.
//

import DomainTesting
import Foundation
import Testing
@testable import Domain

struct SyncReminderUseCaseTests {
    
    @Test func syncOnlyActiveMedication() async throws {
        
        let firstMed = try makeMedication(isActive: true)
        let secondMed = try makeMedication(isActive: true)
        let thirdMed = try makeMedication(isActive: false)
        
        
        let repository = MockMedicationRepository(medications: [firstMed, secondMed, thirdMed])
        
        let scheduler = MockReminderScheduler()
        
        let sut = SyncReminderUseCase(
            repository: repository,
            scheduler: scheduler
        )
        
        try await sut.execute()
        
        #expect(await scheduler.scheduledIds == [firstMed.id, secondMed.id])
        
    }
}
