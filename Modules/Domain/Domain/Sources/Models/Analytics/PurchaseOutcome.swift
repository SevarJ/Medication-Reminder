//
//  PurchaseOutcome.swift
//  Domain
//
//  Created by Sevar Jafarli on 25.10.26.
//

public enum PurchaseOutcome: Sendable, Equatable {
    case purchased(productID: String)
    case pending
    case cancelled
    case failed
}
