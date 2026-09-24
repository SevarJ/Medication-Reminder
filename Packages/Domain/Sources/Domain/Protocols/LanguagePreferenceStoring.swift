//
//  LanguagePreferenceStoring.swift
//  Domain
//
//  Created by Sevar Jafarli on 24.09.26.
//

public protocol LanguagePreferenceStoring: Sendable {
    var language: AppLanguage { get }
    func save(_ language: AppLanguage)
}
