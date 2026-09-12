//
//  MedicationEditorViewModelTests.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 12.09.26.
//

import Domain
import Foundation
import Testing
@testable import MedicationFeature

@MainActor
struct MedicationEditorViewModelTests {
    @Test func savesNewMedicationWithSortedTimes() async throws {
        let repository = MockMedicationRepository()
        let sut = makeSUT(repository: repository)
        sut.name = "Magnesium"
        sut.amountText = "2"
        sut.times = [.at(hour: 21, minute: 30), .at(hour: 8, minute: 0)]
        
        #expect(await sut.save())
        
        let saved = try #require(await repository.medications.first)
        
        #expect(saved.name == "Magnesium")
        #expect(saved.dosage.amount == 2)
        #expect(saved.times.map { $0.hour } == [8, 21])
    }
    
    @Test func rejectsInvalidAmount() async throws {
        let sut = makeSUT()
        sut.name = "Magnesium"
        sut.amountText = "0"
        
        #expect(await sut.save() == false)
        #expect(sut.errorMessage != nil)
    }
    
    @Test func reportsEmptyNameFromDomain() async throws {
        let sut = makeSUT()
        sut.name = "   "
        
        #expect(await sut.save() == false)
        #expect(sut.errorMessage == "Enter a medication name.")
    }
    
    @Test func reportsDuplicateTimes() async throws {
        let sut = makeSUT()
        sut.name = "Magnesium"
        sut.times = [.at(hour: 9, minute: 0), .at(hour: 9, minute: 0)]
        
        #expect(await sut.save() == false)
        #expect(sut.errorMessage == "Reminder times must be different from each other.")
    }
    
    @Test func treatsDeniedNotificationsAsSuccessfulSave() async throws {
        let sut = makeSUT(scheduler: MockReminderScheduler(failsWithAuthorizationDenied: true))
        sut.name = "Magnesium"
        
        #expect(await sut.save())
        #expect(sut.errorMessage == nil)
    }
    
    @Test func preservesIdentityWhenEditing() async throws {
        let repository = MockMedicationRepository()
        let existing = try makeMedication(name: "Vitamin D")
        let sut = makeSUT(repository: repository, medication: existing)
        sut.name = "Vitamin D3"
        
        #expect(await sut.save())
        
        let saved = try #require(await repository.medications.first)
        
        #expect(saved.id == existing.id)
        #expect(saved.name == "Vitamin D3")
        #expect(saved.createdDate == existing.createdDate)
    }
    
    private func makeSUT(
        repository: MockMedicationRepository = MockMedicationRepository(),
        scheduler: MockReminderScheduler = MockReminderScheduler(),
        medication: Medication? = nil
    ) -> MedicationEditorViewModel {
        MedicationEditorViewModel(
            medication: medication,
            saveMedication: SaveMedicationUseCase(
                repository: repository,
                scheduler: scheduler
            )
        )
    }
}
