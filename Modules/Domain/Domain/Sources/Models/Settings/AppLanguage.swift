//
//  AppLanguage.swift
//  Domain
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Foundation

public enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case system
    case english = "en"
    case azerbaijani = "az"
    case russian = "ru"
    
    public static let storageKey = "app.language"
    
    public static var current: AppLanguage {
        UserDefaultsLanguageStore().language
    }
    
    public var id: String { rawValue }
    
    public var code: String? {
        self == .system ? nil : rawValue
    }
    
    public var locale: Locale {
        code.map(Locale.init(identifier:)) ?? .autoupdatingCurrent
    }
}
