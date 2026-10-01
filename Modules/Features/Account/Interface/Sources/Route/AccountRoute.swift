//
//  AccountRoute.swift
//  Account
//
//  Created by Sevar Jafarli on 01.10.26.
//

public enum AccountRoute: Hashable, Identifiable, Sendable {
    case signIn

    public var id: Self { self }
}
