//
//  UpcomingDosePublishing.swift
//  Domain
//
//  Created by Sevar Jafarli on 25.10.26.
//

import Foundation

public protocol UpcomingDosePublishing: Sendable {
    func publish(_ doses: [ScheduledDose]) async
    func clear() async
}
