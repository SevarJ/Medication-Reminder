//
//  UpcomingDoseEntry.swift
//  WidgetSnapshot
//
//  Created by Sevar Jafarli on 25.10.26.
//

import Foundation

public struct UpcomingDoseEntry: Codable, Equatable, Sendable {
    public static let dueSoonWindow: TimeInterval = 30 * 60

    public let medicationId: UUID
    public let name: String
    public let detail: String
    public let date: Date
    public let visibleUntil: Date

    public init(medicationId: UUID, name: String, detail: String, date: Date, visibleUntil: Date) {
        self.medicationId = medicationId
        self.name = name
        self.detail = detail
        self.date = date
        self.visibleUntil = visibleUntil
    }

    public var dueSoonDate: Date {
        date.addingTimeInterval(-Self.dueSoonWindow)
    }

    public func isDueSoon(at now: Date) -> Bool {
        now >= dueSoonDate
    }
}
