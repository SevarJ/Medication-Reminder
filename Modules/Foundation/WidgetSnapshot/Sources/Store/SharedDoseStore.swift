//
//  SharedDoseStore.swift
//  WidgetSnapshot
//
//  Created by Sevar Jafarli on 25.10.26.
//

import Foundation

public struct SharedDoseStore: @unchecked Sendable {
    public static let appGroup = "group.com.sevarjafarli.medora"
    public static let key = "widget.doseSnapshot"

    private let defaults: UserDefaults?

    public init() {
        self.init(defaults: UserDefaults(suiteName: Self.appGroup))
    }

    public init(defaults: UserDefaults?) {
        self.defaults = defaults
    }

    public func load() -> DoseSnapshot {
        guard let data = defaults?.data(forKey: Self.key),
              let snapshot = try? JSONDecoder().decode(DoseSnapshot.self, from: data)
        else {
            return .empty
        }

        return snapshot
    }

    public func save(_ snapshot: DoseSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }

        defaults?.set(data, forKey: Self.key)
    }

    public func clear() {
        defaults?.removeObject(forKey: Self.key)
    }
}
