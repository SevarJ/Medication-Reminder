//
//  NotificationAuthorizing.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.08.26.
//

public protocol NotificationAuthorizing: Sendable {
    func requestAuthorization() async throws -> Bool
}
