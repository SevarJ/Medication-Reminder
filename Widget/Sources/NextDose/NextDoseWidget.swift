//
//  NextDoseWidget.swift
//  MedoraWidget
//
//  Created by Sevar Jafarli on 25.10.26.
//

import SwiftUI
import WidgetKit
import WidgetSnapshot

struct NextDoseWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetKind.nextDose, provider: NextDoseProvider()) { entry in
            NextDoseView(entry: entry)
        }
        .configurationDisplayName(L10n.galleryName)
        .description(L10n.galleryDescription)
        .supportedFamilies([.systemSmall])
    }
}
