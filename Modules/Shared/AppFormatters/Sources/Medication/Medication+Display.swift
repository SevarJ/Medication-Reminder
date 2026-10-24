//
//  Medication+Display.swift
//  AppFormatters
//
//  Created by Sevar Jafarli on 24.10.26.
//

import Domain
import Foundation

public extension Medication {
    var doseText: String {
        [dosage.displayText, intakeTags.displayText]
            .compactMap { $0 }
            .joined(separator: " · ")
    }
}
