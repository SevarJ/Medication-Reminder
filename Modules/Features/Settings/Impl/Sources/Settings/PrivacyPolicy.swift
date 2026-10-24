//
//  PrivacyPolicy.swift
//  SettingsImpl
//
//  Created by Sevar Jafarli on 24.10.26.
//

import Foundation

enum PrivacyPolicy {
    static func url(languageCode: String) -> URL? {
        var components = URLComponents(string: "https://sevarj.github.io/Medication-Reminder/privacy/")
        components?.fragment = languageCode

        return components?.url
    }
}
