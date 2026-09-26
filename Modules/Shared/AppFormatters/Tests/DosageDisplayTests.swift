//
//  DosageDisplayTests.swift
//  AppFormattersTests
//
//  Created by Sevar Jafarli on 26.09.26.
//

import AppFormatters
import Domain
import Testing

struct DosageDisplayTests {
    @Test func pluralizesWholeCounts() {
        #expect(Dosage(amount: 1, unit: .tablet).displayText == "1 tablet")
        #expect(Dosage(amount: 10, unit: .drop).displayText == "10 drops")
    }

    @Test func usesPluralFormForFractionalAmounts() {
        #expect(Dosage(amount: 0.5, unit: .tablet).displayText.hasSuffix(" tablets"))
        #expect(Dosage(amount: 2.5, unit: .mg).displayText.hasSuffix(" mg"))
    }

    @Test func namesEachUnit() {
        #expect(DosageUnit.allCases.map(\.displayText) == ["mg", "ml", "tablet", "drop"])
    }
}
