//
//  L10n.swift
//  Domain
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Foundation

enum L10n {
    enum Dosage {
        static func milligrams(_ amount: String) -> String {
            String(localized: "dosage.milligrams", defaultValue: "\(amount) mg", bundle: .module)
        }
        
        static func milliliters(_ amount: String) -> String {
            String(localized: "dosage.milliliters", defaultValue: "\(amount) ml", bundle: .module)
        }
        
        static func tabletsFraction(_ amount: String) -> String {
            String(localized: "dosage.tablets.fraction", defaultValue: "\(amount) tablets", bundle: .module)
        }
        
        static func dropsFraction(_ amount: String) -> String {
            String(localized: "dosage.drops.fraction", defaultValue: "\(amount) drops", bundle: .module)
        }
        
        static func tablets(_ count: Int) -> String {
            String(localized: "dosage.tablets", defaultValue: "\(count) tablets", bundle: .module)
        }
        
        static func drops(_ count: Int) -> String {
            String(localized: "dosage.drops", defaultValue: "\(count) drops", bundle: .module)
        }
    }
    
    enum Unit {
        static var milligram: String {
            String(localized: "unit.milligram", defaultValue: "mg", bundle: .module)
        }
        
        static var milliliter: String {
            String(localized: "unit.milliliter", defaultValue: "ml", bundle: .module)
        }
        
        static var tablet: String {
            String(localized: "unit.tablet", defaultValue: "tablet", bundle: .module)
        }
        
        static var drop: String {
            String(localized: "unit.drop", defaultValue: "drop", bundle: .module)
        }
    }
}
