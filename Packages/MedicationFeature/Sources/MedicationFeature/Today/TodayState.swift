//
//  TodayState.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Domain

enum TodayState: Equatable {
    case loading
    case empty
    case loaded([ScheduledDose])
    case failure(message: String)
}
