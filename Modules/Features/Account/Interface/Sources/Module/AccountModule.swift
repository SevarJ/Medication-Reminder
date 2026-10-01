//
//  AccountModule.swift
//  Account
//
//  Created by Sevar Jafarli on 01.10.26.
//

import SwiftUI

public protocol AccountModule {
    associatedtype Screen: View

    @MainActor
    func makeScreen(_ route: AccountRoute) -> Screen
}
