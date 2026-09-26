# MedReminder

A medication reminder and adherence tracker for iOS. Schedule medications, get a local notification for every dose, mark each one taken or skipped, and review the last seven days.

<p align="left">
  <a href="https://github.com/SevarJ/Medication-Reminder/actions/workflows/ci.yml"><img src="https://github.com/SevarJ/Medication-Reminder/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <img src="https://img.shields.io/badge/iOS-17%2B-blue" alt="iOS 17+">
  <img src="https://img.shields.io/badge/Swift-6-orange" alt="Swift 6">
  <img src="https://img.shields.io/badge/tests-163-brightgreen" alt="163 tests">
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

  AppLocalization · AppPreferences · DependencyInjection · DesignSystem   Foundation, usable by every layer
```

- `Domain` depends on nothing: no UI, no localization, no storage.
- Data modules implement the protocols `Domain` defines. Features never import them and reach data only through use cases.
- Every module keeps its code `internal` and makes public only its intended API. Tests use `@testable import`.

### Dependency injection

`DependencyInjection` is a small type-keyed container with no third-party code. Each data module exposes only a configurator that registers its implementations of the `Domain` protocols, and the app runs them at launch:

```swift
PersistenceConfigurator.setup()
NotificationsConfigurator.setup()
```

Features resolve the ports they need from the container and build their own use cases and view models, so the app never wires a feature by hand.

### Feature modules

Each feature is an interface target and an `Impl`. The interface holds a route enum and a module protocol with a single associated screen type:

```swift
public enum DashboardRoute: Hashable, Identifiable, Sendable {
    case today(reloadToken: Int)
    case medications
    case doseReminder(medicationId: UUID, scheduledDate: Date)
}

public protocol DashboardModule {
    associatedtype Screen: View

    @MainActor
    func makeScreen(_ route: DashboardRoute) -> Screen
}
```

Everything in the `Impl` is internal. `DashboardModuleImpl` conforms to the protocol and switches over the route, and the only public symbol is a configurator that returns an opaque module:

```swift
public enum DashboardModuleConfigurator {
    public static func makeModule() -> some DashboardModule {
        DashboardModuleImpl()
    }
}
```

The opaque return type keeps every view and view model hidden without `AnyView`. Adding a screen means adding a route case, so the protocol does not grow. Screens that are presented close themselves with SwiftUI's `dismiss` action. An `Impl` can use other features' interfaces but never another `Impl`.

### Composition root

The app target is the only one that knows every `Impl`. It gets each module from its configurator and passes it to a generic `RootView`, which sees only the interfaces:

```swift
RootView(
    router: router,
    dashboard: DashboardModuleConfigurator.makeModule(),
    settings: SettingsModuleConfigurator.makeModule(),
    onboarding: OnboardingModuleConfigurator.makeModule()
)
```

Navigation uses route values. Tapping a reminder notification sets `DashboardRoute.doseReminder` on the router, which presents the dose screen, and onboarding reports a pending `OnboardingRoute` that drives the notification priming sheet.

| Layer | Module | Responsibility |
| --- | --- | --- |
| Foundation | `AppLocalization` | App language, localized bundle lookup and strings every screen shares |
| Foundation | `AppPreferences` | UserDefaults keys and typed accessors for app preferences |
| Foundation | `DependencyInjection` | Type-keyed dependency container |
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

## Tests

Every module has its own test target, and the `MedReminder` scheme runs them all:

```bash
xcodebuild test -workspace MedReminder.xcworkspace -scheme MedReminder -destination 'platform=iOS Simulator,name=iPhone 17'
```

CI generates the project, checks the module dependencies, runs the tests and builds the Release app on every push to `main`.
