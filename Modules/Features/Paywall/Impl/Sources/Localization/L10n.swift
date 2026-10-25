//
//  L10n.swift
//  PaywallImpl
//
//  Created by Sevar Jafarli on 25.10.26.
//

import AppLocalization
import Foundation

enum L10n {
    static var message: String {
        String(localized: "paywall.message", defaultValue: "Get every Pro feature.", bundle: .module.localized())
    }

    static var restore: String {
        String(localized: "paywall.action.restore", defaultValue: "Restore", bundle: .module.localized())
    }

    static var close: String {
        String(localized: "paywall.action.close", defaultValue: "Close", bundle: .module.localized())
    }

    static var pending: String {
        String(localized: "paywall.notice.pending", defaultValue: "Your purchase is waiting for approval.", bundle: .module.localized())
    }

    static var nothingToRestore: String {
        String(localized: "paywall.notice.nothingToRestore", defaultValue: "No purchases to restore.", bundle: .module.localized())
    }
}
