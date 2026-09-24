//
//  SettingsOption+Display.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 24.09.26.
//

import DesignSystem
import Domain

extension AppLanguage {
    var displayName: String {
        switch self {
        case .system: L10n.Settings.systemLanguage
        case .english: "English"
        case .azerbaijani: "Azərbaycanca"
        case .russian: "Русский"
        }
    }
}

extension AppAppearance {
    var displayName: String {
        switch self {
        case .system: L10n.Settings.appearanceSystem
        case .light: L10n.Settings.appearanceLight
        case .dark: L10n.Settings.appearanceDark
        }
    }
}
