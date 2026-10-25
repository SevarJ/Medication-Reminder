//
//  IntroductionPage.swift
//  OnboardingImpl
//
//  Created by Sevar Jafarli on 25.10.26.
//

enum IntroductionPage: Int, CaseIterable, Identifiable {
    case reminders
    case today
    case stock

    var id: Self { self }

    var systemImage: String {
        switch self {
        case .reminders: "bell.badge.fill"
        case .today: "checklist"
        case .stock: "pills.fill"
        }
    }

    var title: String {
        switch self {
        case .reminders: L10n.Introduction.remindersTitle
        case .today: L10n.Introduction.todayTitle
        case .stock: L10n.Introduction.stockTitle
        }
    }

    var message: String {
        switch self {
        case .reminders: L10n.Introduction.remindersMessage
        case .today: L10n.Introduction.todayMessage
        case .stock: L10n.Introduction.stockMessage
        }
    }

    var next: IntroductionPage? {
        IntroductionPage(rawValue: rawValue + 1)
    }
}
