//
//  MedTime.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.08.26.
//

import Foundation

public struct MedTime: Identifiable, Equatable, Hashable, Sendable, Comparable {
    public let id: UUID
    public let hour: Int
    public let minute: Int

    public init(
        id: UUID = UUID(),
        hour: Int,
        minute: Int
    ) throws {
        guard (0..<24).contains(hour),
              (0..<60).contains(minute) else {
            throw DomainError.invalidTime
        }

        self.id = id
        self.hour = hour
        self.minute = minute
    }
    
    public static func < (lhs: MedTime, rhs: MedTime) -> Bool {
        (lhs.hour, lhs.minute) < (rhs.hour, rhs.minute)
    }
}
