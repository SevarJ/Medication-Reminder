//
//  DoseLink.swift
//  WidgetSnapshot
//
//  Created by Sevar Jafarli on 25.10.26.
//

import Foundation

public struct DoseLink: Equatable, Sendable {
    public static let scheme = "medora"
    static let host = "dose"

    public let medicationId: UUID
    public let scheduledDate: Date

    public init(medicationId: UUID, scheduledDate: Date) {
        self.medicationId = medicationId
        self.scheduledDate = scheduledDate
    }

    public init?(url: URL) {
        guard url.scheme == Self.scheme,
              url.host() == Self.host,
              let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
              let id = items.first(where: { $0.name == "medication" })?.value.flatMap(UUID.init(uuidString:)),
              let time = items.first(where: { $0.name == "date" })?.value.flatMap(TimeInterval.init)
        else {
            return nil
        }

        self.init(medicationId: id, scheduledDate: Date(timeIntervalSince1970: time))
    }

    public var url: URL? {
        var components = URLComponents()
        components.scheme = Self.scheme
        components.host = Self.host
        components.queryItems = [
            URLQueryItem(name: "medication", value: medicationId.uuidString),
            URLQueryItem(name: "date", value: String(scheduledDate.timeIntervalSince1970)),
        ]

        return components.url
    }
}
