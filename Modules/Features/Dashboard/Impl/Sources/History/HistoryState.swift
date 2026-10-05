//
//  HistoryState.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 05.10.26.
//

import Domain

enum HistoryState: Equatable {
    case loading
    case loaded([DoseDaySummary])
    case failure
}
