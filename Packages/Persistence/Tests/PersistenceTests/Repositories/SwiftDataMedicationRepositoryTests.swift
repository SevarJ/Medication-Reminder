//
//  SwiftDataMedicationRepositoryTests.swift
//  Persistence
//
//  Created by Sevar Jafarli on 12.09.26.
//

import Domain
import Foundation
import Testing
@testable import Persistence

struct SwiftDataMedicationRepositoryTests {
    private func makeSUT() throws -> any MedicationRepository {
        try PersistenceFactory.makeStore(inMemory: true).medications
    }
    
    private func makeMedication(
        id: UUID = UUID(),
        name: String = "Vitamin D",
        times: [(Int, Int)] = [(9, 0), (21, 30)],
        recurrence: Recurrence = .daily,
        isActive: Bool = true,
        createdDate: Date = .now
    ) throws -> Medication {
        Medication(
            id: id,
            name: name,
            dosage: Dosage(amount: 2.5, unit: .ml),
            schedule: MedicationSchedule(
                times: try times.map { try MedTime(hour: $0.0, minute: $0.1) },
                recurrence: recurrence,
                startDate: createdDate
            ),
            isActive: isActive,
            createdDate: createdDate
        )
    }
    
    @Test func savesAndFetchesMedication() async throws {
        let sut = try makeSUT()
        let medication = try makeMedication()
        
        try await sut.save(medication)
        
        let stored = try await sut.fetch(id: medication.id)
        
        #expect(stored.name == medication.name)
        #expect(stored.dosage == medication.dosage)
        #expect(stored.schedule.times.map { $0.hour } == [9, 21])
        #expect(stored.isActive)
    }
    
    @Test func savingExistingMedicationUpdatesInPlace() async throws {
        let sut = try makeSUT()
        let medication = try makeMedication()
        
        try await sut.save(medication)
        try await sut.save(medication.updating(isActive: false))
        
        let all = try await sut.fetchAll()
        
        #expect(all.count == 1)
        #expect(all.first?.isActive == false)
    }
    
    @Test func fetchAllIsSortedByCreationDate() async throws {
        let sut = try makeSUT()
        let older = try makeMedication(name: "Older", createdDate: .now.addingTimeInterval(-60))
        let newer = try makeMedication(name: "Newer")
        
        try await sut.save(newer)
        try await sut.save(older)
        
        #expect(try await sut.fetchAll().map { $0.name } == ["Older", "Newer"])
    }
    
    @Test func deleteRemovesMedication() async throws {
        let sut = try makeSUT()
        let medication = try makeMedication()
        
        try await sut.save(medication)
        try await sut.delete(id: medication.id)
        
        #expect(try await sut.fetchAll().isEmpty)
    }
    
    @Test func fetchingMissingMedicationThrows() async throws {
        let sut = try makeSUT()
        
        await #expect(throws: DomainError.medicationNotFound) {
            try await sut.fetch(id: UUID())
        }
    }
    
    @Test func storesWeekdayRecurrence() async throws {
        let sut = try makeSUT()
        let medication = try makeMedication(recurrence: .daysOfWeek([.monday, .friday]))
        
        try await sut.save(medication)
        
        let stored = try await sut.fetch(id: medication.id)
        
        #expect(stored.schedule.recurrence == .daysOfWeek([.monday, .friday]))
    }
    
    @Test func mapperRejectsUnknownDosageUnit() async throws {
        let entity = MedicationEntity(
            id: UUID(),
            name: "Vitamin D",
            dosageAmount: 1,
            dosageUnit: "spoon",
            times: [],
            recurrenceKind: "daily",
            recurrenceDays: [],
            startDate: .now,
            endDate: nil,
            isActive: true,
            createdDate: .now
        )
        
        #expect(throws: PersistenceError.unknownDosageUnit("spoon")) {
            try MedicationMapper.toDomain(entity)
        }
    }
}
