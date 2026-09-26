//
//  DoseAssembler.swift
//  Domain
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Foundation

enum DoseAssembler {
    static func doses(
        for medications: [Medication],
        on date: Date,
        logs: [DoseLog],
        calendar: Calendar
    ) -> [ScheduledDose] {
        let logsByDose = Dictionary(
            logs.map { log in
                (ScheduledDose.ID(medicationId: log.medicationId, scheduledDate: log.scheduledDate), log)
            },
            uniquingKeysWith: { _, latest in latest }
        )
        
        return medications
            .flatMap { medication in
                medication.schedule
                    .doses(on: date, calendar: calendar)
                    .map { scheduledDate in
                        let id = ScheduledDose.ID(medicationId: medication.id, scheduledDate: scheduledDate)
                        
                        return ScheduledDose(
                            medication: medication,
                            scheduledDate: scheduledDate,
                            log: logsByDose[id]
                        )
                    }
            }
            .sorted { ($0.scheduledDate, $0.medication.name) < ($1.scheduledDate, $1.medication.name) }
    }
}
