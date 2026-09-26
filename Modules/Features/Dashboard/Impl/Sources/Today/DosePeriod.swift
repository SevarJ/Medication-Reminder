//
//  DosePeriod.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Foundation

enum DosePeriod: CaseIterable, Identifiable {
    case morning
    case afternoon
    case evening
    
    static func of(_ date: Date) -> DosePeriod {
        switch date.hourAndMinute.hour {
        case ..<12: .morning
        case 12..<18: .afternoon
        default: .evening
        }
    }
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .morning: L10n.Today.morning
        case .afternoon: L10n.Today.afternoon
        case .evening: L10n.Today.evening
        }
    }
    
    var iconName: String {
        switch self {
        case .morning: "sunrise.fill"
        case .afternoon: "sun.max.fill"
        case .evening: "moon.stars.fill"
        }
    }
}
