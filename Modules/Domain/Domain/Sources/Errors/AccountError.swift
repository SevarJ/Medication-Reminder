//
//  AccountError.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.10.26.
//

public enum AccountError: Error, Equatable, Sendable {
    case signInCancelled
    case signInFailed
}
