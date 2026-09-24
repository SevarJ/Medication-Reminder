# MedReminder

A medication reminder and adherence tracker for iOS. Schedule medications, get a local notification for every dose, mark each one taken or skipped, and review the last seven days.

<p align="left">
  <a href="https://github.com/SevarJ/Medication-Reminder/actions/workflows/ci.yml"><img src="https://github.com/SevarJ/Medication-Reminder/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <img src="https://img.shields.io/badge/iOS-17%2B-blue" alt="iOS 17+">
  <img src="https://img.shields.io/badge/Swift-6-orange" alt="Swift 6">
  <img src="https://img.shields.io/badge/tests-119-brightgreen" alt="119 tests">
</p>

## Features

- Add, edit and delete medications with dosage and unit (mg, ml, tablet, drop)
- Schedule doses every day or on selected weekdays, with an optional start and end date
- Multiple daily reminder times per medication
- Repeating local notifications, rescheduled automatically whenever a medication changes
- Mark a dose taken or skipped from the Today screen, or straight from the notification
- Snooze a reminder for ten minutes without opening the app
- Seven-day history with adherence, and late corrections inside that window
- Per-medication on/off switch that cancels or restores its reminders
- Warning banner when notification permission is missing, with reminders re-synced as soon as it is granted
- Local persistence with SwiftData
- Available in English, Azerbaijani and Russian, including plural-aware dosage text
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
| `Domain` | `Medication`, `MedicationSchedule`, `DoseLog`, use cases, repository and scheduler protocols |
| `Persistence` | SwiftData implementations of `MedicationRepository` and `DoseLogRepository` |
| `NotificationsKit` | `UserNotifications` implementation of reminder scheduling, actions and authorization |
| `DesignSystem` | Colors, typography, spacing and reusable components |
| `DIContainer` | Lightweight dependency container |
| `MedicationFeature` | Today, History, list and editor screens with their view models |

## Tech stack

Swift 6 with strict concurrency · SwiftUI · SwiftData · UserNotifications · Swift Testing · Swift Package Manager
