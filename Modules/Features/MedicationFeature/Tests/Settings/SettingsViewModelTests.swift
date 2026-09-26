//
//  SettingsViewModelTests.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 24.09.26.
//

import AppLocalization
import Domain
import Foundation
import Testing
@testable import MedicationFeature

@MainActor
struct SettingsViewModelTests {
    private let store: UserDefaultsLanguageStore
    
    init() throws {
        let defaults = try #require(UserDefaults(suiteName: "SettingsViewModelTests.\(UUID().uuidString)"))
        store = UserDefaultsLanguageStore(defaults: defaults)
    }
    
    private func makeSUT(
        authorizer: MockNotificationAuthorizer = MockNotificationAuthorizer(),
        scheduler: MockReminderScheduler = MockReminderScheduler(),
        medications: [Medication] = []
    ) -> SettingsViewModel {
        let syncReminder = SyncReminderUseCase(
            repository: MockMedicationRepository(medications: medications),
            scheduler: scheduler
        )
        
        return SettingsViewModel(
            languageStore: store,
            syncReminder: syncReminder,
            authorizer: authorizer,
            appVersion: "1.0 (1)"
        )
    }
    
    @Test func startsWithStoredLanguage() {
        store.save(.russian)
        
        let sut = makeSUT()
        
        #expect(sut.language == .russian)
    }
    
    @Test func selectingLanguageSavesItAndReschedulesReminders() async throws {
        let medication = try makeMedication()
        let scheduler = MockReminderScheduler()
        let sut = makeSUT(scheduler: scheduler, medications: [medication])
        
        await sut.select(.azerbaijani)
        
        #expect(sut.language == .azerbaijani)
        #expect(store.language == .azerbaijani)
        #expect(await scheduler.scheduledIds == [medication.id])
    }
    
    @Test func selectingLanguageWithoutNotificationAccessStillSavesIt() async throws {
        let sut = makeSUT(
            scheduler: MockReminderScheduler(failsWithAuthorizationDenied: true),
            medications: [try makeMedication()]
        )
        
        await sut.select(.english)
        
        #expect(store.language == .english)
        #expect(sut.errorMessage == nil)
    }
    
    @Test func resolvesStringsFromChosenLanguage() {
        let expected: [AppLanguage: String] = [.english: "Settings", .azerbaijani: "Ayarlar", .russian: "Настройки"]
        
        for (language, value) in expected {
            let bundle = Bundle.module.localized(for: language)
            
            #expect(String(localized: "settings.title", bundle: bundle) == value)
        }
    }
    
    @Test func startLoadsNotificationAccess() async {
        let sut = makeSUT(authorizer: MockNotificationAuthorizer(access: .denied))
        
        await sut.start()
        
        #expect(sut.notificationAccess == .denied)
    }
    
    @Test func enablingNotificationsRequestsAccessAndSchedulesReminders() async throws {
        let medication = try makeMedication()
        let authorizer = MockNotificationAuthorizer(access: .notDetermined)
        let scheduler = MockReminderScheduler()
        let sut = makeSUT(authorizer: authorizer, scheduler: scheduler, medications: [medication])
        
        await sut.enableNotifications()
        
        #expect(sut.notificationAccess == .authorized)
        #expect(await authorizer.requestCount == 1)
        #expect(await scheduler.scheduledIds == [medication.id])
    }
    
    @Test func refusedNotificationsSkipReminderSync() async throws {
        let scheduler = MockReminderScheduler()
        let sut = makeSUT(
            authorizer: MockNotificationAuthorizer(access: .notDetermined, grantsOnRequest: false),
            scheduler: scheduler,
            medications: [try makeMedication()]
        )
        
        await sut.enableNotifications()
        
        #expect(sut.notificationAccess == .denied)
        #expect(await scheduler.scheduledIds.isEmpty)
    }
}
