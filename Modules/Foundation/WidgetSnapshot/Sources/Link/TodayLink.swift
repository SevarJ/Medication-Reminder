//
//  TodayLink.swift
//  WidgetSnapshot
//
//  Created by Sevar Jafarli on 25.10.26.
//

import Foundation

public enum TodayLink {
    static let host = "today"

    public static var url: URL? {
        var components = URLComponents()
        components.scheme = DoseLink.scheme
        components.host = host

        return components.url
    }

    public static func matches(_ url: URL) -> Bool {
        url.scheme == DoseLink.scheme && url.host() == host
    }
}
