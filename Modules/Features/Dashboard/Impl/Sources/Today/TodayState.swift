//
//  TodayState.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Domain

enum TodayState: Equatable {
    case loading
    case loaded([DoseDaySummary])
    case failure(message: String)
}
