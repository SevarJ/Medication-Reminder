//
//  Bundle+AppLanguage.swift
//  AppLocalization
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Foundation

public extension Bundle {
    func localized(for language: AppLanguage = .current) -> Bundle {
        guard let code = language.code,
              let path = path(forResource: code, ofType: "lproj"),
              let bundle = Bundle(path: path)
        else {
            return self
        }
        
        return bundle
    }
}
