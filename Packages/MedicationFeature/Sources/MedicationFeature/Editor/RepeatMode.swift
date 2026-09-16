//
//  RepeatMode.swift
//  MedicationFeature
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
        case .daily: "Every Day"
        case .specificDays: "Specific Days"
        }
    }
}
