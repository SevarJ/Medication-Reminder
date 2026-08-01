//
//  DomainError.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.08.26.
//

public enum DomainError: Error, Equatable, Sendable {
    case nameEmpty
    case timeUnselected
    case invalidTime
    case medicationNotFound
    case duplicateTime
}
