//
//  ReminderRequest.swift
//  NotificationsKit
//
//  Created by Sevar Jafarli on 12.09.26.
//

import Foundation

struct ReminderRequest: Sendable, Equatable {
    let identifier: String
    let medicationId: UUID
    let title: String
    let body: String
    let components: DateComponents
    let repeats: Bool
    
    var hour: Int? { components.hour }
    var minute: Int? { components.minute }
    var weekday: Int? { components.weekday }
}
