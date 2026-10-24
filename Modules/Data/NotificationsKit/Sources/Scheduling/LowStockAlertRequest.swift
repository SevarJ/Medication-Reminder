//
//  LowStockAlertRequest.swift
//  NotificationsKit
//
//  Created by Sevar Jafarli on 24.10.26.
//

import Foundation

struct LowStockAlertRequest: Sendable, Equatable {
    let identifier: String
    let medicationId: UUID
    let title: String
    let body: String
    let fireDate: Date?
}
