//
//  MockAccountDataRemoteStore.swift
//  DomainTesting
//
//  Created by Sevar Jafarli on 24.10.26.
//

import Domain

public actor MockAccountDataRemoteStore: AccountDataRemoteStore {
    public private(set) var deleteAllCount = 0

    private let fails: Bool

    public init(fails: Bool = false) {
        self.fails = fails
    }

    public func deleteAll() async throws {
        deleteAllCount += 1

        if fails {
            throw PersistenceFailure()
        }
    }
}
