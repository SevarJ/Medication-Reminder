//
//  DoseLogRemoteStore.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.10.26.
//

import Foundation

/// The signed-in account's dose logs on the server.
public protocol DoseLogRemoteStore: Sendable {
    /// Logs scheduled on or after `date` and, when `end` is given, before it. Needs a connection, and fails without one instead of answering from an offline copy.
    func fetch(from date: Date, to end: Date?) async throws -> [DoseLog]
    /// Writes are queued and return straight away. They reach the server once there is a connection.
    func save(_ log: DoseLog) async throws
    func delete(id: UUID) async throws
    func deleteAll(medicationId: UUID) async throws
}

public extension DoseLogRemoteStore {
    func fetch(from date: Date) async throws -> [DoseLog] {
        try await fetch(from: date, to: nil)
    }
}
