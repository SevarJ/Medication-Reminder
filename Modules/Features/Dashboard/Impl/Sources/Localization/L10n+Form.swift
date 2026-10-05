//
//  L10n+Form.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 06.10.26.
//

import AppLocalization
import Foundation

private func string(_ key: StaticString, _ defaultValue: String.LocalizationValue) -> String {
    String(localized: key, defaultValue: defaultValue, table: "MedicationForm", bundle: .module.localized())
}

extension L10n {
    /// The add and edit flow, and the stock and notes it brings to the other screens.
    enum Form {
        static var detailsTitle: String { string("form.step.details.title", "Medication") }
        static var scheduleTitle: String { string("form.step.schedule.title", "Schedule") }
        static var durationTitle: String { string("form.step.duration.title", "Duration") }
        static var extrasTitle: String { string("form.step.extras.title", "Stock and notes") }
        
        static var detailsQuestion: String { string("form.step.details.question", "What are you taking?") }
        static var scheduleQuestion: String { string("form.step.schedule.question", "When do you take it?") }
        static var durationQuestion: String { string("form.step.duration.question", "How long will you take it?") }
        static var extrasQuestion: String { string("form.step.extras.question", "Anything else?") }
        
        static func from(_ date: String) -> String { string("form.from", "From \(date)") }
        static var leftSuffix: String { string("form.left", "left") }
        static var notSet: String { string("form.notSet", "Not set") }
        static var invalidStock: String { string("form.error.stock", "Enter an amount of zero or more.") }
        
        static var next: String { string("form.next", "Next") }
        static var back: String { string("form.back", "Back") }
        static func stepOf(_ step: Int, _ total: Int) -> String { string("form.stepOf", "Step \(step) of \(total)") }
        
        static var addPhoto: String { string("form.photo.add", "Add photo") }
        static var changePhoto: String { string("form.photo.change", "Change photo") }
        static var removePhoto: String { string("form.photo.remove", "Remove photo") }
        static var photoHint: String { string("form.photo.hint", "Optional. A picture of the box helps you recognise it.") }
        
        static var decreaseDose: String { string("form.dose.decrease", "Decrease dose") }
        static var increaseDose: String { string("form.dose.increase", "Increase dose") }
        
        static var removeTime: String { string("form.time.remove", "Remove time") }
        static var stockTitle: String { string("form.stock.title", "How much do you have?") }
        static var stockHint: String { string("form.stock.hint", "Optional. Each dose you take is subtracted, and you'll see when you're running low.") }
        static var notesTitle: String { string("form.notes.title", "Notes") }
        static var notesPlaceholder: String { string("form.notes.placeholder", "For example, take with food") }
        
        static func stockLeft(_ amount: String) -> String { string("form.stock.left", "\(amount) left") }
        static var stockOut: String { string("form.stock.out", "Out of stock") }
        static func daysLeft(_ days: Int) -> String { string("form.stock.days", "About \(days) days left") }
    }
}
