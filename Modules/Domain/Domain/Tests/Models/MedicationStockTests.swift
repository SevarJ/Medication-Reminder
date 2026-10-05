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
}
