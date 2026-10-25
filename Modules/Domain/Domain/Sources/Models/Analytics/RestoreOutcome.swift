//
//  RestoreOutcome.swift
//  Domain
//
//  Created by Sevar Jafarli on 25.10.26.
//

public enum RestoreOutcome: Sendable, Equatable {
    case restored
    case nothingToRestore
    case failed
}
