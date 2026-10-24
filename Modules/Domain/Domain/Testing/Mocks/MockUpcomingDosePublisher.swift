//
//  MockUpcomingDosePublisher.swift
//  DomainTesting
//
//  Created by Sevar Jafarli on 25.10.26.
//

import Domain

public actor MockUpcomingDosePublisher: UpcomingDosePublishing {
    public private(set) var published: [[ScheduledDose]] = []
    public private(set) var clearCount = 0

    public init() {}

    public func publish(_ doses: [ScheduledDose]) async {
        published.append(doses)
    }

    public func clear() async {
        clearCount += 1
    }
}
