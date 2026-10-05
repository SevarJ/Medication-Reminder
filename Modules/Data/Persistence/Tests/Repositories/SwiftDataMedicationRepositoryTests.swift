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
    private func makeSUT() throws -> any MedicationCache {
        try PersistenceFactory.makeStore(inMemory: true).medications
    }
    
    private func makeMedication(
        id: UUID = UUID(),
        name: String = "Vitamin D",
        times: [(Int, Int)] = [(9, 0), (21, 30)],
        recurrence: Recurrence = .daily,
        isActive: Bool = true,
        createdDate: Date = .now,
        photo: Data? = nil,
        notes: String? = nil,
        stock: Double? = nil
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
            createdDate: createdDate,
            photo: photo,
            notes: notes,
            stock: stock
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
    
    @Test func storesPhotoNotesAndStock() async throws {
        let sut = try makeSUT()
        let medication = try makeMedication(photo: Data([1, 2, 3]), notes: "With food", stock: 12)
        
        try await sut.save(medication)
        
        let stored = try await sut.fetch(id: medication.id)
        
        #expect(stored.photo == Data([1, 2, 3]))
        #expect(stored.notes == "With food")
        #expect(stored.stock == 12)
    }
    
    @Test func clearingTheExtrasRemovesThem() async throws {
        let sut = try makeSUT()
        let medication = try makeMedication(photo: Data([1]), notes: "Note", stock: 3)
        
        try await sut.save(medication)
        try await sut.save(
            Medication(
                id: medication.id,
                name: medication.name,
                dosage: medication.dosage,
                schedule: medication.schedule,
                isActive: true,
                createdDate: medication.createdDate
            )
        )
        
        let stored = try await sut.fetch(id: medication.id)
        
        #expect(stored.photo == nil)
        #expect(stored.notes == nil)
        #expect(stored.stock == nil)
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
    
    @Test func replaceAllKeepsExactlyTheGivenMedications() async throws {
        let sut = try makeSUT()
        let removed = try makeMedication(name: "Removed")
        let kept = try makeMedication(name: "Kept")
        let added = try makeMedication(name: "Added")
        
        try await sut.save(removed)
        try await sut.save(kept)
        try await sut.replaceAll(with: [kept.updating(isActive: false), added])
        
        let all = try await sut.fetchAll()
        
        #expect(Set(all.map { $0.id }) == [kept.id, added.id])
        #expect(all.first { $0.id == kept.id }?.isActive == false)
    }
    
    @Test func replaceAllTakesOverTheCreationDate() async throws {
        let sut = try makeSUT()
        let medication = try makeMedication()
        let earlier = Date(timeIntervalSince1970: 1_700_000_000)
        
        try await sut.save(medication)
        try await sut.replaceAll(with: [try makeMedication(id: medication.id, createdDate: earlier)])
        
        #expect(try await sut.fetch(id: medication.id).createdDate == earlier)
    }
    
    @Test func replaceAllWithNothingEmptiesTheCache() async throws {
        let sut = try makeSUT()
        
        try await sut.save(try makeMedication())
        try await sut.replaceAll(with: [])
        
        #expect(try await sut.fetchAll().isEmpty)
    }
}
