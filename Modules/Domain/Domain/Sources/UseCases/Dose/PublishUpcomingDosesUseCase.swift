//
//  PublishUpcomingDosesUseCase.swift
//  Domain
//
//  Created by Sevar Jafarli on 25.10.26.
//

import Foundation

public struct PublishUpcomingDosesUseCase: Sendable {
    public static let dayCount = 7
    public static let doseLimit = 40
    public static let overdueWindow: TimeInterval = 30 * 60

    private let medicationRepository: any MedicationRepository
    private let doseLogRepository: any DoseLogRepository
    private let publisher: any UpcomingDosePublishing
    private let calendar: Calendar

    public init(
        medicationRepository: any MedicationRepository,
        doseLogRepository: any DoseLogRepository,
        publisher: any UpcomingDosePublishing,
        calendar: Calendar = .current
    ) {
        self.medicationRepository = medicationRepository
        self.doseLogRepository = doseLogRepository
        self.publisher = publisher
        self.calendar = calendar
    }

    public func execute(now: Date = .now) async throws {
        let today = calendar.startOfDay(for: now)

        guard let endOfRange = calendar.date(byAdding: .day, value: Self.dayCount, to: today) else { return }

        let medications = try await medicationRepository
            .fetchAll()
            .filter { $0.isActive }
        let logs = try await doseLogRepository.fetch(from: today, to: endOfRange)
        let earliest = now.addingTimeInterval(-Self.overdueWindow)

        let doses = (0..<Self.dayCount)
            .compactMap { calendar.date(byAdding: .day, value: $0, to: today) }
            .flatMap { day in
                DoseAssembler.doses(for: medications, on: day, logs: logs, calendar: calendar)
            }
            .filter { $0.log == nil && $0.scheduledDate > earliest }

        await publisher.publish(Array(doses.prefix(Self.doseLimit)))
    }

    public func clear() async {
        await publisher.clear()
    }
}
