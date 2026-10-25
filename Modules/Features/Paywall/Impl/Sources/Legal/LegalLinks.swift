//
//  LegalLinks.swift
//  PaywallImpl
//
//  Created by Sevar Jafarli on 25.10.26.
//

import AppLocalization
import Foundation

enum LegalLinks {
    static let termsOfUse = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!

    static var privacyPolicy: URL {
        var components = URLComponents(string: "https://sevarj.github.io/Medication-Reminder/privacy/")!
        components.fragment = AppLanguage.current.code ?? Bundle.module.preferredLocalizations.first ?? "en"

        return components.url!
    }
}
