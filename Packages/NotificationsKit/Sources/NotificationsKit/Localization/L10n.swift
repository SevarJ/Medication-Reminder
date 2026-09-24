//
//  L10n.swift
//  NotificationsKit
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Domain
import Foundation

enum L10n {
    enum Action {
        static var taken: String {
            String(localized: "action.taken", defaultValue: "Taken", bundle: .module.localized())
        }
        
        static var skip: String {
            String(localized: "action.skip", defaultValue: "Skip", bundle: .module.localized())
        }
        
        static var snooze: String {
            String(localized: "action.snooze", defaultValue: "Snooze 10 min", bundle: .module.localized())
        }
    }
}
