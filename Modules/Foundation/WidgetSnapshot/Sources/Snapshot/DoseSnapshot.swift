//
//  DoseSnapshot.swift
//  WidgetSnapshot
//
//  Created by Sevar Jafarli on 25.10.26.
//

import Foundation

public struct DoseSnapshot: Codable, Equatable, Sendable {
    public static let empty = DoseSnapshot(doses: [], languageCode: nil)

    public let doses: [UpcomingDoseEntry]
    public let languageCode: String?

    public init(doses: [UpcomingDoseEntry], languageCode: String?) {
        self.doses = doses
        self.languageCode = languageCode
    }

    public func doses(visibleAt date: Date) -> [UpcomingDoseEntry] {
        doses.filter { $0.visibleUntil > date }
    }
}
