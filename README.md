# Medora

A medication reminder and adherence tracker for iOS. Schedule medications, get a local notification for every dose, mark each one taken or skipped, and review your whole history in a calendar.

<p align="left">
  <a href="https://github.com/SevarJ/Medication-Reminder/actions/workflows/ci.yml"><img src="https://github.com/SevarJ/Medication-Reminder/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <img src="https://img.shields.io/badge/iOS-17%2B-blue" alt="iOS 17+">
  <img src="https://img.shields.io/badge/Swift-6-orange" alt="Swift 6">
  <img src="https://img.shields.io/badge/tests-290-brightgreen" alt="290 tests">
</p>

## Features

- Google sign-in, with medications and dose history stored in Cloud Firestore and cached offline
- Medications with dosage, unit, weekdays, date range and several daily reminder times
- Local notifications with take and snooze actions
- Medication page with a seven-day adherence summary, pause and delete
- Today screen with next dose, daily progress and a seven-day week strip
- History tab with a month calendar and totals, going back to your first medication
- English, Azerbaijani and Russian
- Light and dark appearance, Dynamic Type

## Architecture

Modular clean architecture generated with [Tuist](https://tuist.dev). Every layer is a group of small framework modules, and a module may only depend on the layers below it. The Tuist helpers reject any other dependency when the project is generated, and CI runs `tuist inspect dependencies` to catch implicit or redundant imports.

```
                               ┌──────────────┐
                               │    Medora    │  app target, composition root
                               └──────┬───────┘
      ┌──────────────────┬────────────┴─────┬──────────────────┐
┌─────┴───────┐  ┌───────┴────────┐  ┌──────┴────────┐  ┌──────┴───────┐
│ AccountImpl │  │ OnboardingImpl │  │ DashboardImpl │  │ SettingsImpl │   Features
│   Account   │  │   Onboarding   │  │   Dashboard   │  │   Settings   │   impl + interface
└─────┬───────┘  └───────┬────────┘  └──────┬────────┘  └──────┬───────┘
      └──────────────────┴────────────┬─────┴──────────────────┘
                              ┌───────┴───────┐
                              │ AppFormatters │                            Shared
                              └───────┬───────┘
┌─────────────┐  ┌──────────────────┐ │  ┌─────────────┐  ┌──────────┐
│ Persistence │  │ NotificationsKit │ │  │ FirebaseKit │  │ DataSync │    Data
└──────┬──────┘  └─────────┬────────┘ │  └──────┬──────┘  └─────┬────┘
       └───────────────────┴──────────┼─────────┴───────────────┘
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
FirebaseConfigurator.setup()
PersistenceConfigurator.setup()
NotificationsConfigurator.setup()
DataSyncConfigurator.setup()
```

Third-party SDKs are linked only by data modules, which list them as `packages` in `Project.swift`. `FirebaseKit` is the only module that imports Firebase or Google Sign-In.

Features resolve the ports they need from the container and build their own use cases and view models, so the app never wires a feature by hand.

### Data sync

Firestore holds the account's data and SwiftData is a cache of it. Data modules cannot depend on each other, so each side implements a `Domain` port and `DataSync` joins them:

- `Persistence` implements `MedicationCache` and `DoseLogCache`, `FirebaseKit` implements `MedicationRemoteStore` and `DoseLogRemoteStore`.
- `DataSync` registers the `MedicationRepository` and `DoseLogRepository` the features use. Reads come from the cache. A write goes to the cache and then to Firestore, which queues it while the device is offline.
- `RefreshAccountDataUseCase` replaces the cache with what the server holds and reschedules the reminders that changed. `SessionStore` runs it when a session starts and when the app returns from the background. Offline it fails and the cache stays as it is. Only the last 14 days of dose logs are cached; older ones stay on the server, and the History tab reads them from there one month at a time (`LoadMonthHistoryUseCase`), keeping each month in memory until the app closes. Older months need a connection.
- `ClearLocalDataUseCase` runs on sign-out and on every launch that finds nobody signed in.

Documents live under the account: `users/{uid}/medications/{medicationId}` and `users/{uid}/doseLogs/{logId}`.

## Design

`DesignSystem` holds the tokens and shared components. Screens use them instead of raw colors or sizes.

- Colors: `ThemeColors` has one green accent, neutral surfaces, `warning` for missed doses, `info` for skipped ones and `danger` for destructive actions
- Components: `cardSurface()`, the `.primaryAction`, `.heroAction` and `.secondaryAction` button styles, `HeroGlyph`, `IconTile`, `Badge` and `ProgressRing`
- Dynamic Type: `AdaptiveStack` stacks a row vertically at accessibility sizes
- iOS 26 gets Liquid Glass bars from the system, and the minimum stays iOS 17

## Tech stack

Swift 6 with strict concurrency · SwiftUI · SwiftData · UserNotifications · Firebase Authentication · Cloud Firestore · Google Sign-In · Swift Testing · Tuist

## Getting started

The Xcode project is generated with Tuist, whose version is pinned in `mise.toml`.

```bash
brew install mise
mise install
make
```

`make` generates `Medora.xcworkspace` and opens it. `make generate` does the same without opening Xcode; run it after editing `Project.swift` or the helpers in `Tuist/ProjectDescriptionHelpers`. Adding or removing files inside a module does not need it. `make help` lists the other commands.

## Adding a feature

Declare the feature in `Project.swift`, add it to `features`, and run `make generate`:

```swift
let profile = Feature.feature("Profile")
```

For every declared feature that has no folder yet, `make generate` runs the `feature` Tuist template before generating the project. It writes `Modules/Features/Profile` with the `Profile` interface (`ProfileRoute` and the `ProfileModule` protocol), a `ProfileImpl` with the module implementation, its configurator and a starter view and view model, and a test target with a view model test. The template can also be run on its own with `tuist scaffold feature --name Profile`.

The starter code imports only its own interface, so the feature starts with no dependencies. Add a module to `dependencies` or `testDependencies` when the code starts importing it; `make generate` and CI fail on an import that is not declared and on a declared dependency that is not imported.

## Tests

Every module has its own test target, and the `Medora` scheme runs them all:

```bash
xcodebuild test -workspace Medora.xcworkspace -scheme Medora -destination 'platform=iOS Simulator,name=iPhone 17'
```

CI generates the project, checks the module dependencies, runs the tests and builds the Release app on every push to `main`.
