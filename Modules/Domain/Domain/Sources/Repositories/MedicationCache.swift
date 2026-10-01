//
//  MedicationCache.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.10.26.
//

/// The copy of the account's medications kept on the device.
public protocol MedicationCache: MedicationRepository {
    /// Makes the cache hold exactly `medications`. An empty list wipes it.
    func replaceAll(with medications: [Medication]) async throws
}
