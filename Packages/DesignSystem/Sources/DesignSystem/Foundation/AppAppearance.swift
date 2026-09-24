//
//  AppAppearance.swift
//  DesignSystem
//
//  Created by Sevar Jafarli on 24.09.26.
//

import SwiftUI

public enum AppAppearance: String, CaseIterable, Identifiable, Sendable {
    case system
    case light
    case dark
    
    public static let storageKey = "app.appearance"
    
    public var id: String { rawValue }
    
    public var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
