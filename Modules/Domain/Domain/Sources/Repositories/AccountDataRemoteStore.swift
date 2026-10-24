//
//  AccountDataRemoteStore.swift
//  Domain
//
//  Created by Sevar Jafarli on 24.10.26.
//

public protocol AccountDataRemoteStore: Sendable {
    func deleteAll() async throws
}
