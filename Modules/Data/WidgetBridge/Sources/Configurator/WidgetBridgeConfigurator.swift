//
//  WidgetBridgeConfigurator.swift
//  WidgetBridge
//
//  Created by Sevar Jafarli on 25.10.26.
//

import DependencyInjection
import Domain

public enum WidgetBridgeConfigurator {
    public static func setup(in container: DependencyContainer = .shared) {
        container.registerSingleton((any UpcomingDosePublishing).self) { WidgetBridgeFactory.makePublisher() }
    }
}
