# MedReminder

A medication reminder and adherence tracker for iOS. Schedule medications, get a local notification for every dose, mark each one taken or skipped, and review the last seven days.

<p align="left">
  <a href="https://github.com/SevarJ/Medication-Reminder/actions/workflows/ci.yml"><img src="https://github.com/SevarJ/Medication-Reminder/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <img src="https://img.shields.io/badge/iOS-17%2B-blue" alt="iOS 17+">
  <img src="https://img.shields.io/badge/Swift-6-orange" alt="Swift 6">
  <img src="https://img.shields.io/badge/tests-155-brightgreen" alt="155 tests">
</p>

## Features

- Add, edit and delete medications with dosage and unit (mg, ml, tablet, drop)
- Schedule doses every day or on selected weekdays, with an optional start and end date
- Multiple daily reminder times per medication
- Repeating local notifications, rescheduled automatically whenever a medication changes
- Reminders are time-sensitive, so they still arrive while a Focus mode is on
- Mark a dose taken or skipped from the Today screen, or straight from the notification
- Snooze a reminder without opening the app, for 5, 10, 15 or 30 minutes as chosen in Settings
- Tapping a reminder opens a full-screen dose card to mark it taken or snooze it
- Today screen with a daily progress ring, a next-dose card and a seven-day week strip for reviewing and correcting past days
- Animated, haptic dose check-off with swipe to take or skip
- Per-medication on/off switch that cancels or restores its reminders
- Warning banner when notification permission is missing, with reminders re-synced as soon as it is granted
- Local persistence with SwiftData
- Available in English, Azerbaijani and Russian, including plural-aware dosage text
- Settings screen with an in-app language switch that applies instantly and re-localizes scheduled reminders
- Light and dark appearance that follows the system or is chosen in Settings, Dynamic Type support

## Architecture

Modular clean architecture generated with [Tuist](https://tuist.dev). Every layer is a group of small framework modules, and a module may only depend on the layers below it. The Tuist helpers reject any other dependency when the project is generated, and CI runs `tuist inspect dependencies` to catch implicit or redundant imports.

```
                          ┌──────────────┐
                          │ MedReminder  │  app target, composition root
                          └──────┬───────┘
        ┌────────────────────────┼─────────────────────────┐
┌───────┴────────┐       ┌───────┴────────┐       ┌────────┴───────┐
│ OnboardingImpl │       │ DashboardImpl  │       │  SettingsImpl  │   Features
│   Onboarding   │       │   Dashboard    │       │    Settings    │   impl + interface
└───────┬────────┘       └───────┬────────┘       └────────┬───────┘
        └────────────────────────┼─────────────────────────┘
                         ┌───────┴───────┐
                         │ AppFormatters │                             Shared
                         └───────┬───────┘
     ┌─────────────┐             │             ┌──────────────────┐
     │ Persistence │             │             │ NotificationsKit │    Data
     └──────┬──────┘             │             └─────────┬────────┘
            └────────────────────┼───────────────────────┘
                           ┌─────┴─────┐
                           │  Domain   │  entities, use cases, ports    Domain
                           └───────────┘

      AppLocalization · AppPreferences · DesignSystem                   Foundation, usable by every layer
```

- `Domain` depends on nothing: no UI, no localization, no storage.
- Data modules implement the protocols `Domain` defines. Features never import them and reach data only through use cases.
- Each feature is an interface target and an `Impl`. The interface holds the feature's contract (the dependencies it needs and its value types), the `Impl` exposes only its entry screens and keeps every view model and view internal. An `Impl` can use other features' interfaces but never another `Impl`.
- The app target is the only one that knows every `Impl`. `AppContainer` builds the services and use cases once and wires them with plain constructor injection.

| Layer | Module | Responsibility |
| --- | --- | --- |
| Foundation | `AppLocalization` | App language, localized bundle lookup and strings every screen shares |
| Foundation | `AppPreferences` | UserDefaults keys and typed accessors for app preferences |
| Foundation | `DesignSystem` | Colors, typography, spacing and reusable components |
| Domain | `Domain` | `Medication`, `MedicationSchedule`, `DoseLog`, use cases, repository and scheduler protocols |
| Domain | `DomainTesting` | Mocks and factories shared by the test targets |
| Shared | `AppFormatters` | Dosage text and error messages used by several screens and by notifications |
| Data | `Persistence` | SwiftData implementations of `MedicationRepository` and `DoseLogRepository` |
| Data | `NotificationsKit` | `UserNotifications` implementation of reminder scheduling, actions and authorization |
| Features | `Onboarding` / `OnboardingImpl` | Notification permission priming |
| Features | `Dashboard` / `DashboardImpl` | Today, medication list and editor, and the dose reminder screen |
| Features | `Settings` / `SettingsImpl` | Language, appearance, notification and snooze settings |

## Tech stack

Swift 6 with strict concurrency · SwiftUI · SwiftData · UserNotifications · Swift Testing · Tuist

## Getting started

The Xcode project is generated with Tuist, whose version is pinned in `mise.toml`.

```bash
brew install mise
mise install
tuist install
tuist generate
```

`tuist generate` creates `MedReminder.xcworkspace` and opens it. Regenerate only after editing `Project.swift` or the helpers in `Tuist/ProjectDescriptionHelpers`; adding or removing files inside a module does not need it.
