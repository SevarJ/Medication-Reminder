//
//  MockRemoteOfflineStore.swift
//  DomainTesting
//
//  Created by Sevar Jafarli on 01.10.26.
//

import Domain

public actor MockRemoteOfflineStore: RemoteOfflineStore {
    public private(set) var clearCount = 0

    public init() {}

    public func clear() async throws {
        clearCount += 1
    }
}
