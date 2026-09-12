# MedReminder

A medication reminder app for iOS. Add your medications, set one or more daily times, and get a repeating local notification for each dose.

<p align="left">
  <a href="https://github.com/SevarJ/Medication-Reminder/actions/workflows/ci.yml"><img src="https://github.com/SevarJ/Medication-Reminder/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <img src="https://img.shields.io/badge/iOS-17%2B-blue" alt="iOS 17+">
  <img src="https://img.shields.io/badge/Swift-6-orange" alt="Swift 6">
  <img src="https://img.shields.io/badge/tests-55-brightgreen" alt="55 tests">
</p>

## Features

- Add, edit and delete medications with dosage and unit (mg, ml, tablet, drop)
- Multiple daily reminder times per medication
- Repeating local notifications, rescheduled automatically whenever a medication changes
- Per-medication on/off switch that cancels or restores its reminders
- Warning banner when notification permission is missing, with reminders re-synced as soon as it is granted
- Local persistence with SwiftData
- Light and dark appearance, Dynamic Type support

## Architecture

Clean-architecture layering, with every layer in its own Swift package. Dependencies point inward only — `Domain` knows nothing about the frameworks around it.

```
        ┌──────────────────────────┐
        │       MedReminder        │  app target, composition root
        └────────────┬─────────────┘
                     │
        ┌────────────┴─────────────┐
        │    MedicationFeature     │  SwiftUI screens + @Observable view models
        └────────────┬─────────────┘
                     │
   ┌─────────────┬───┴────┬──────────────┬─────────────┐
   │ Persistence │ Notifi-│ DesignSystem │ DIContainer │
   │ (SwiftData) │ cations│  (tokens +   │             │
   │             │  Kit   │  components) │             │
   └──────┬──────┴───┬────┴──────────────┴─────────────┘
          │          │
        ┌─┴──────────┴─┐
        │    Domain    │  entities, use cases, protocols
        └──────────────┘
```

| Package | Responsibility |
| --- | --- |
| `Domain` | `Medication`, `Dosage`, `MedTime`, use cases, repository and scheduler protocols |
| `Persistence` | SwiftData implementation of `MedicationRepository` |
| `NotificationsKit` | `UserNotifications` implementation of reminder scheduling and authorization |
| `DesignSystem` | Colors, typography, spacing and reusable components |
| `DIContainer` | Lightweight dependency container |
| `MedicationFeature` | List and editor screens with their view models |

## Tech stack

Swift 6 with strict concurrency · SwiftUI · SwiftData · UserNotifications · Swift Testing · Swift Package Manager
