//
//  MedicationEditorViewModelTests.swift
//  DashboardImplTests
//
//  Created by Sevar Jafarli on 12.09.26.
//

import Domain
import DomainTesting
import Foundation
import Testing
@testable import DashboardImpl

@MainActor
struct MedicationEditorViewModelTests {
    @Test func savesNewMedicationWithSortedTimes() async throws {
        let repository = MockMedicationRepository()
        let sut = makeSUT(repository: repository)
        sut.name = "Magnesium"
        sut.amountText = "2"
        sut.times = [
            try MedTime(hour: 21, minute: 30),
            try MedTime(hour: 8, minute: 0),
        ]
        
        #expect(await sut.save())
        
        let saved = try #require(await repository.medications.first)
        
        #expect(saved.name == "Magnesium")
        #expect(saved.dosage.amount == 2)
        #expect(saved.schedule.times.map { $0.hour } == [8, 21])
    }
    
    @Test func removingTimeKeepsAtLeastOneReminder() async throws {
        let sut = makeSUT()
        sut.times = [
            try MedTime(hour: 9, minute: 0),
            try MedTime(hour: 21, minute: 0),
        ]
        
        let removed = try #require(sut.times.last)
        
        sut.removeTime(id: removed.id)
        
        #expect(sut.times.count == 1)
        
        sut.removeTime(id: try #require(sut.times.first).id)
        
        #expect(sut.times.count == 1)
    }
    
    @Test func savesSelectedWeekdays() async throws {
        let repository = MockMedicationRepository()
        let sut = makeSUT(repository: repository)
        sut.name = "Magnesium"
        sut.repeatMode = .specificDays
        sut.toggleWeekday(.monday)
        sut.toggleWeekday(.friday)
        
        #expect(await sut.save())
        
        let saved = try #require(await repository.medications.first)
        
        #expect(saved.schedule.recurrence == .daysOfWeek([.monday, .friday]))
    }
    
    @Test func reportsMissingWeekdays() async throws {
        let sut = makeSUT()
        sut.name = "Magnesium"
        sut.repeatMode = .specificDays
        
        #expect(await sut.save() == false)
        #expect(sut.errorMessage == "Select at least one day of the week.")
    }
    
    @Test func savesEndDateOnlyWhenEnabled() async throws {
        let repository = MockMedicationRepository()
        let sut = makeSUT(repository: repository)
        sut.name = "Magnesium"
        sut.hasEndDate = true
        sut.endDate = sut.startDate.addingTimeInterval(7 * 24 * 60 * 60)
        
        #expect(await sut.save())
        
        let saved = try #require(await repository.medications.first)
        
        #expect(saved.schedule.endDate != nil)
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
        sut.times = [
            try MedTime(hour: 9, minute: 0),
            try MedTime(hour: 9, minute: 0),
        ]
        
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
