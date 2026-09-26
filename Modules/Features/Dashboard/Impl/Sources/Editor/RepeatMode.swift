//
//  RepeatMode.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 12.09.26.
//

import Domain

enum RepeatMode: CaseIterable, Identifiable {
    case daily
    case specificDays
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .daily: L10n.Editor.everyDay
        case .specificDays: L10n.Editor.specificDays
        }
    }
}
