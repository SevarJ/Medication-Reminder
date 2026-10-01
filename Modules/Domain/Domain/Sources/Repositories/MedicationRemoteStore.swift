//
//  MedicationRemoteStore.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.10.26.
//

import Foundation

/// The signed-in account's medications on the server.
public protocol MedicationRemoteStore: Sendable {
    /// Needs a connection, and fails without one instead of answering from an offline copy.
    func fetchAll() async throws -> [Medication]
    /// Writes are queued and return straight away. They reach the server once there is a connection.
    func save(_ medication: Medication) async throws
    func delete(id: UUID) async throws
}
