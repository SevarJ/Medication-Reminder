//
//  UserProfileRepository.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.10.26.
//

public protocol UserProfileRepository: Sendable {
    func save(_ account: UserAccount) async throws
}
