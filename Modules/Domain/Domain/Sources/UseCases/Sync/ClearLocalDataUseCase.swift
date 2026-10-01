//
//  ClearLocalDataUseCase.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.10.26.
//

/// Removes everything the account left on the device: reminders, the cache and the remote store's offline copy.
/// The account's data on the server stays.
public struct ClearLocalDataUseCase: Sendable {
    private let medicationCache: any MedicationCache
    private let doseLogCache: any DoseLogCache
    private let remoteOffline: any RemoteOfflineStore
    private let scheduler: any ReminderScheduling
    
    public init(
        medicationCache: any MedicationCache,
        doseLogCache: any DoseLogCache,
        remoteOffline: any RemoteOfflineStore,
        scheduler: any ReminderScheduling
    ) {
        self.medicationCache = medicationCache
        self.doseLogCache = doseLogCache
        self.remoteOffline = remoteOffline
        self.scheduler = scheduler
    }
    
    /// Every step runs even when an earlier one fails, and the first failure is thrown at the end.
    public func execute() async throws {
        let steps: [@Sendable () async throws -> Void] = [
            { try await scheduler.cancelAll() },
            { try await medicationCache.replaceAll(with: []) },
            { try await doseLogCache.replaceAll(with: []) },
            { try await remoteOffline.clear() },
        ]
        var failure: (any Error)?
        
        for step in steps {
            do {
                try await step()
            }
            catch {
                failure = failure ?? error
            }
        }
        
        if let failure {
            throw failure
        }
    }
}
