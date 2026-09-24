//
//  L10n.swift
//  NotificationsKit
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Foundation

enum L10n {
    enum Action {
        static var taken: String {
            String(localized: "action.taken", defaultValue: "Taken", bundle: .module)
        }
        
        static var skip: String {
            String(localized: "action.skip", defaultValue: "Skip", bundle: .module)
        }
        
        static var snooze: String {
            String(localized: "action.snooze", defaultValue: "Snooze 10 min", bundle: .module)
        }
    }
}
