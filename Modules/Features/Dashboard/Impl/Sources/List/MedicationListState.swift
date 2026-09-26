//
//  MedicationListState.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 12.09.26.
//

import Domain

enum MedicationListState: Equatable {
    case loading
    case empty
    case loaded([Medication])
    case failure(message: String)
}
