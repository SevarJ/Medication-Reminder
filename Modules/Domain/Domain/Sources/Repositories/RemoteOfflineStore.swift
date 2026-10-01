//
//  RemoteOfflineStore.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.10.26.
//

/// What the remote store keeps on the device: writes still waiting for a connection and copies of what it has read.
public protocol RemoteOfflineStore: Sendable {
    /// Deletes everything kept on the device, including writes that were never sent. Server data is untouched.
    func clear() async throws
}
