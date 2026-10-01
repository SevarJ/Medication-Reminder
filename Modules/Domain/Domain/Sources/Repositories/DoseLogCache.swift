//
//  DoseLogCache.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.10.26.
//

/// The copy of the account's recent dose logs kept on the device.
public protocol DoseLogCache: DoseLogRepository {
    /// Makes the cache hold exactly `logs`. An empty list wipes it.
    func replaceAll(with logs: [DoseLog]) async throws
}
