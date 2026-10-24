//
//  WidgetBridgeFactory.swift
//  WidgetBridge
//
//  Created by Sevar Jafarli on 25.10.26.
//

import Domain
import WidgetKit
import WidgetSnapshot

enum WidgetBridgeFactory {
    static func makePublisher() -> any UpcomingDosePublishing {
        WidgetDosePublisher(
            store: SharedDoseStore(),
            reloadWidgets: { WidgetCenter.shared.reloadTimelines(ofKind: WidgetKind.nextDose) }
        )
    }
}
