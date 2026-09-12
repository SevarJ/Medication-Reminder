//
//  Mocks.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 12.09.26.
//

import Domain
import Foundation

actor MockMedicationRepository: MedicationRepository {
    private(set) var medications: [Medication]
    private(set) var deletedIds: [UUID] = []
    
    private let fetchAllFails: Bool
    private var fetchAllHook: (@Sendable () async -> Void)?
    
    init(medications: [Medication] = [], fetchAllFails: Bool = false) {
        self.medications = medications
        self.fetchAllFails = fetchAllFails
    }
    
    func setFetchAllHook(_ hook: @escaping @Sendable () async -> Void) {
        fetchAllHook = hook
    }
    
    func fetchAll() async throws -> [Medication] {
        await fetchAllHook?()
        
        if fetchAllFails {
            throw PersistenceFailure()
        }
        
        return medications
    }
    
    func fetch(id: UUID) async throws -> Medication {
        guard let medication = medications.first(where: { $0.id == id }) else {
            throw DomainError.medicationNotFound
        }
        
        return medication
    }
    
    func save(_ medication: Medication) async throws {
        medications.removeAll { $0.id == medication.id }
        medications.append(medication)
    }
    
    func delete(id: UUID) async throws {
        deletedIds.append(id)
        medications.removeAll { $0.id == id }
    }
}

actor MockReminderScheduler: ReminderScheduling {
    private(set) var scheduledIds: [UUID] = []
    private(set) var cancelledIds: [UUID] = []
    
    private let failsWithAuthorizationDenied: Bool
    
    init(failsWithAuthorizationDenied: Bool = false) {
        self.failsWithAuthorizationDenied = failsWithAuthorizationDenied
    }
    
    func schedule(for medication: Medication) async throws {
        if failsWithAuthorizationDenied {
            throw ReminderError.authorizationDenied
        }
        
        scheduledIds.append(medication.id)
    }
    
    func cancel(for medicationId: UUID) async throws {
        cancelledIds.append(medicationId)
    }
}

struct PersistenceFailure: Error {}

struct MockNotificationAuthorizer: NotificationAuthorizing {
    let result: Bool
    
    func requestAuthorization() async throws -> Bool {
        result
    }
}

func makeMedication(
    id: UUID = UUID(),
    name: String = "Vitamin D",
    times: [(Int, Int)] = [(9, 0)],
    isActive: Bool = true,
    createdDate: Date = .now
) throws -> Medication {
    Medication(
        id: id,
        name: name,
        dosage: Dosage(amount: 1, unit: .tablet),
        times: try times.map { try MedTime(hour: $0.0, minute: $0.1) },
        isActive: isActive,
        createdDate: createdDate
    )
}
