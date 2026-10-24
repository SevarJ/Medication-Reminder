//
//  DoseLinkTests.swift
//  WidgetSnapshot
//
//  Created by Sevar Jafarli on 25.10.26.
//

import Foundation
import Testing
@testable import WidgetSnapshot

struct DoseLinkTests {
    @Test func linkSurvivesTheRoundTrip() throws {
        let link = DoseLink(medicationId: UUID(), scheduledDate: Date(timeIntervalSince1970: 1_793_000_000))

        #expect(DoseLink(url: try #require(link.url)) == link)
    }

    @Test func ignoresOtherSchemes() throws {
        #expect(DoseLink(url: try #require(URL(string: "https://example.com/dose?medication=x&date=1"))) == nil)
    }

    @Test func ignoresALinkWithoutAMedication() throws {
        #expect(DoseLink(url: try #require(URL(string: "medora://dose?date=1"))) == nil)
    }
}
