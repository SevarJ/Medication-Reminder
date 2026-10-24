//
//  MedicationStockTests.swift
//  Domain
//
//  Created by Sevar Jafarli on 06.10.26.
//

import DomainTesting
import Foundation
import Testing
@testable import Domain

struct MedicationStockTests {
    private let calendar = Calendar(identifier: .gregorian)
    
    private func date(day: Int, hour: Int, minute: Int) throws -> Date {
        try #require(
            calendar.date(from: DateComponents(year: 2026, month: 10, day: day, hour: hour, minute: minute))
        )
    }
    
    @Test func noStockMeansNoEstimate() throws {
        #expect(try makeMedication().daysOfStockLeft == nil)
    }
    
    @Test func estimatesDaysForDailyDoses() throws {
        let medication = try makeMedication(dosage: Dosage(amount: 1, unit: .tablet), times: [(9, 0), (21, 0)], stock: 20)
        
        #expect(medication.daysOfStockLeft == 10)
    }
    
    @Test func usesTheDosageAmount() throws {
        let medication = try makeMedication(dosage: Dosage(amount: 2, unit: .tablet), stock: 20)
        
        #expect(medication.daysOfStockLeft == 10)
    }
    
    @Test func spreadsSpecificDaysOverTheWeek() throws {
        let medication = try makeMedication(dosage: Dosage(amount: 1, unit: .tablet), recurrence: .daysOfWeek([.monday, .thursday]), stock: 4)
        
        #expect(medication.daysOfStockLeft == 14)
    }
    
    @Test func roundsDown() throws {
        let medication = try makeMedication(dosage: Dosage(amount: 3, unit: .tablet), stock: 10)
        
        #expect(medication.daysOfStockLeft == 3)
    }
    
    @Test func emptyStockLastsNoDays() throws {
        #expect(try makeMedication(stock: 0).daysOfStockLeft == 0)
    }
    
    @Test func noStockMeansNoAlert() throws {
        #expect(try makeMedication().lowStockAlertDate(now: try date(day: 24, hour: 12, minute: 0), calendar: calendar) == nil)
    }
    
    @Test func alertsAtTheFirstDoseThreeDaysBeforeRunningOut() throws {
        let medication = try makeMedication(
            dosage: Dosage(amount: 1, unit: .tablet),
            times: [(21, 0), (9, 0)],
            startDate: try date(day: 1, hour: 0, minute: 0),
            stock: 20
        )
        
        let alert = medication.lowStockAlertDate(now: try date(day: 24, hour: 12, minute: 0), calendar: calendar)
        
        #expect(alert == (try date(day: 31, hour: 9, minute: 0)))
    }
    
    @Test func alertsOnTheNextDayWithADose() throws {
        let medication = try makeMedication(
            dosage: Dosage(amount: 1, unit: .tablet),
            recurrence: .daysOfWeek([.monday]),
            startDate: try date(day: 1, hour: 0, minute: 0),
            stock: 1
        )
        
        let alert = medication.lowStockAlertDate(now: try date(day: 20, hour: 12, minute: 0), calendar: calendar)
        
        #expect(alert == (try date(day: 26, hour: 9, minute: 0)))
    }
    
    @Test func alertsNowWhenAlreadyLow() throws {
        let now = try date(day: 24, hour: 12, minute: 0)
        let medication = try makeMedication(dosage: Dosage(amount: 1, unit: .tablet), stock: 3)
        
        #expect(medication.lowStockAlertDate(now: now, calendar: calendar) == now)
    }
    
    @Test func noAlertWhenTheStockOutlastsTheCourse() throws {
        let medication = try makeMedication(
            dosage: Dosage(amount: 1, unit: .tablet),
            startDate: try date(day: 1, hour: 0, minute: 0),
            endDate: try date(day: 25, hour: 0, minute: 0),
            stock: 2
        )
        
        #expect(medication.lowStockAlertDate(now: try date(day: 24, hour: 12, minute: 0), calendar: calendar) == nil)
    }
}
