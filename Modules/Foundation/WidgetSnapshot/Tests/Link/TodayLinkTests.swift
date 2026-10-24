//
//  TodayLinkTests.swift
//  WidgetSnapshot
//
//  Created by Sevar Jafarli on 25.10.26.
//

import Foundation
import Testing
@testable import WidgetSnapshot

struct TodayLinkTests {
    @Test func recognisesItsOwnLink() throws {
        #expect(TodayLink.matches(try #require(TodayLink.url)))
    }

    @Test func isNotADoseLink() throws {
        let url = try #require(TodayLink.url)

        #expect(DoseLink(url: url) == nil)
        #expect(TodayLink.matches(try #require(DoseLink(medicationId: UUID(), scheduledDate: .now).url)) == false)
    }
}
