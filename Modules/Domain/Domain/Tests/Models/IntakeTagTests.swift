//
//  IntakeTagTests.swift
//  Domain
//
//  Created by Sevar Jafarli on 24.10.26.
//

import Testing
@testable import Domain

struct IntakeTagTests {
    @Test func customTagIsTrimmed() {
        #expect(IntakeTag.custom(named: "  With water  ") == .custom("With water"))
    }

    @Test func blankCustomTagIsRejected() {
        #expect(IntakeTag.custom(named: "   ") == nil)
    }

    @Test func customTagIsCutToTheLimit() {
        let tag = IntakeTag.custom(named: String(repeating: "a", count: IntakeTag.customLimit + 5))

        #expect(tag == .custom(String(repeating: "a", count: IntakeTag.customLimit)))
    }

    @Test func onlyCustomTagsAreCustom() {
        #expect(IntakeTag.custom("Night").isCustom)
        #expect(IntakeTag.presets.allSatisfy { !$0.isCustom })
    }
}
