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
    private(set) var snoozedIds: [UUID] = []
    
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
    
    func snooze(_ medication: Medication, until date: Date) async throws {
        snoozedIds.append(medication.id)
    }
}

actor MockDoseLogRepository: DoseLogRepository {
    private(set) var logs: [DoseLog]
    
    init(logs: [DoseLog] = []) {
        self.logs = logs
    }
    
    func fetch(from: Date, to: Date) async throws -> [DoseLog] {
        logs.filter { $0.scheduledDate >= from && $0.scheduledDate < to }
    }
    
    func save(_ log: DoseLog) async throws {
        logs.removeAll { $0.id == log.id }
        logs.append(log)
    }
    
    func delete(id: UUID) async throws {
        logs.removeAll { $0.id == id }
    }
    
    func deleteAll(medicationId: UUID) async throws {
        logs.removeAll { $0.medicationId == medicationId }
    }
}

struct PersistenceFailure: Error {}

actor MockNotificationAuthorizer: NotificationAuthorizing {
    private(set) var requestCount = 0
    
    private var currentAccess: NotificationAccess
    private let grantsOnRequest: Bool
    
    init(access: NotificationAccess = .authorized, grantsOnRequest: Bool = true) {
        self.currentAccess = access
        self.grantsOnRequest = grantsOnRequest
    }
    
    func setAccess(_ access: NotificationAccess) {
        currentAccess = access
    }
    
    func requestAuthorization() async throws -> Bool {
        requestCount += 1
        
        if currentAccess == .notDetermined {
            currentAccess = grantsOnRequest ? .authorized : .denied
        }
        
        return currentAccess == .authorized
    }
    
    func access() async -> NotificationAccess {
        currentAccess
    }
}

func makeMedication(
    id: UUID = UUID(),
    name: String = "Vitamin D",
    times: [(Int, Int)] = [(9, 0)],
    recurrence: Recurrence = .daily,
    isActive: Bool = true,
    createdDate: Date = .now
) throws -> Medication {
    Medication(
        id: id,
        name: name,
        dosage: Dosage(amount: 1, unit: .tablet),
        schedule: MedicationSchedule(
            times: try times.map { try MedTime(hour: $0.0, minute: $0.1) },
            recurrence: recurrence,
            startDate: createdDate
        ),
        isActive: isActive,
        createdDate: createdDate
    )
}
