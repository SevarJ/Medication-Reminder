//
//  UserDefaultsLanguageStore.swift
//  AppLocalization
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Foundation

public struct UserDefaultsLanguageStore: LanguagePreferenceStoring, @unchecked Sendable {
    private let defaults: UserDefaults
    
    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    public var language: AppLanguage {
        defaults.string(forKey: AppLanguage.storageKey).flatMap(AppLanguage.init) ?? .system
    }
    
    public func save(_ language: AppLanguage) {
        if language == .system {
            defaults.removeObject(forKey: AppLanguage.storageKey)
        }
        else {
            defaults.set(language.rawValue, forKey: AppLanguage.storageKey)
        }
    }
}
