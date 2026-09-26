//
//  DoseReminderViewModel.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 24.09.26.
//

import AppFormatters
import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class DoseReminderViewModel: Identifiable {
    public let id = UUID()
    
    private(set) var state: DoseReminderState = .loading
    private(set) var isFinished = false
    var errorMessage: String?
    
    private let medicationId: UUID
    private let scheduledDate: Date
    private let loadDose: LoadScheduledDoseUseCase
    private let recordDose: RecordDoseUseCase
    private let snoozeReminder: SnoozeReminderUseCase
    private let snoozeDelay: TimeInterval
    private let currentDate: @Sendable () -> Date
    
    public init(
        medicationId: UUID,
        scheduledDate: Date,
        loadDose: LoadScheduledDoseUseCase,
        recordDose: RecordDoseUseCase,
        snoozeReminder: SnoozeReminderUseCase,
        snoozeDelay: TimeInterval = SnoozeReminderUseCase.defaultDelay,
        currentDate: @escaping @Sendable () -> Date = { .now }
    ) {
        self.medicationId = medicationId
        self.scheduledDate = scheduledDate
        self.loadDose = loadDose
        self.recordDose = recordDose
        self.snoozeReminder = snoozeReminder
        self.snoozeDelay = snoozeDelay
        self.currentDate = currentDate
    }
    
    var snoozeMinutes: Int {
        Int(snoozeDelay / 60)
    }
    
    func load() async {
        do {
            state = .loaded(try await loadDose.execute(medicationId: medicationId, scheduledDate: scheduledDate))
        }
        catch {
            state = .failure(message: ErrorFormatter.message(for: error))
        }
    }
    
    func take() async {
        guard case .loaded(let dose) = state, dose.log?.status != .taken else { return }
        
        do {
            state = .loaded(try await recordDose.execute(dose, status: .taken, now: currentDate()))
            isFinished = true
        }
        catch {
            errorMessage = ErrorFormatter.message(for: error)
        }
    }
    
    func snooze() async {
        do {
            try await snoozeReminder.execute(medicationId: medicationId, delay: snoozeDelay, now: currentDate())
            isFinished = true
        }
        catch {
            errorMessage = ErrorFormatter.message(for: error)
        }
    }
}

enum DoseReminderState: Equatable {
    case loading
    case loaded(ScheduledDose)
    case failure(message: String)
}
