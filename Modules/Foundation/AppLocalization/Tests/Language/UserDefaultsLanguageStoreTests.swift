//
//  UserDefaultsLanguageStoreTests.swift
//  AppLocalizationTests
//
//  Created by Sevar Jafarli on 24.09.26.
//

@testable import AppLocalization
import Foundation
import Testing

struct UserDefaultsLanguageStoreTests {
    private let defaults: UserDefaults
    
    init() throws {
        defaults = try #require(UserDefaults(suiteName: "AppLanguageTests.\(UUID().uuidString)"))
    }
    
    @Test func followsSystemUntilLanguageIsChosen() {
        let store = UserDefaultsLanguageStore(defaults: defaults)
        
        #expect(store.language == .system)
    }
    
    @Test func persistsChosenLanguage() {
        UserDefaultsLanguageStore(defaults: defaults).save(.azerbaijani)
        
        #expect(UserDefaultsLanguageStore(defaults: defaults).language == .azerbaijani)
    }
    
    @Test func choosingSystemClearsStoredLanguage() {
        let store = UserDefaultsLanguageStore(defaults: defaults)
        
        store.save(.russian)
        store.save(.system)
        
        #expect(defaults.object(forKey: AppLanguage.storageKey) == nil)
        #expect(store.language == .system)
    }
}
