//
//  AnalyticsTracking.swift
//  Domain
//
//  Created by Sevar Jafarli on 25.10.26.
//

public protocol AnalyticsTracking: Sendable {
    func track(_ event: AnalyticsEvent) async
}
