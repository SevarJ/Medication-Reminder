//
//  L10n.swift
//  NotificationsKit
//
//  Created by Sevar Jafarli on 24.09.26.
//

internal import AppLocalization
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
        
        static func snooze(minutes: Int) -> String {
            String(localized: "action.snooze", defaultValue: "Snooze \(minutes) min", bundle: .module.localized())
        }
    }
    
    enum LowStock {
        static func daysLeft(_ days: Int) -> String {
            String(localized: "lowStock.daysLeft", defaultValue: "About \(days) days left. Time to refill.", bundle: .module.localized())
        }
        
        static var outOfStock: String {
            String(localized: "lowStock.out", defaultValue: "Out of stock. Time to refill.", bundle: .module.localized())
        }
    }
}
