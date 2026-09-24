//
//  HistoryState.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Domain

enum HistoryState: Equatable {
    case loading
    case empty
    case loaded([DoseDaySummary])
    case failure(message: String)
}
