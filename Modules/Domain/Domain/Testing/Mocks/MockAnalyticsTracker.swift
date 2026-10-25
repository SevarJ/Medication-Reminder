//
//  MockAnalyticsTracker.swift
//  DomainTesting
//
//  Created by Sevar Jafarli on 25.10.26.
//

import Domain

public actor MockAnalyticsTracker: AnalyticsTracking {
    public private(set) var events: [AnalyticsEvent] = []

    public init() {}

    public func track(_ event: AnalyticsEvent) async {
        events.append(event)
    }
}
