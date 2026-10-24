//
//  L10n.swift
//  MedoraWidget
//
//  Created by Sevar Jafarli on 25.10.26.
//

import AppLocalization
import Foundation

enum L10n {
    static let galleryName = LocalizedStringResource("widget.gallery.name", defaultValue: "Next dose")
    static let galleryDescription = LocalizedStringResource("widget.gallery.description", defaultValue: "Shows the next medication to take.")

    static func nextDose(_ language: AppLanguage) -> String {
        String(localized: "widget.nextDose", defaultValue: "Next dose", bundle: .main.localized(for: language))
    }

    static func tomorrow(_ language: AppLanguage) -> String {
        String(localized: "widget.tomorrow", defaultValue: "Tomorrow", bundle: .main.localized(for: language))
    }

    static func noDoses(_ language: AppLanguage) -> String {
        String(localized: "widget.noDoses", defaultValue: "No upcoming doses", bundle: .main.localized(for: language))
    }
}
