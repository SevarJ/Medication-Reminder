//
//  MedicationListViewModelTests.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 12.09.26.
//

import Domain
import Foundation
import Testing
@testable import MedicationFeature

extension MedicationListState {
    var medications: [Medication]? {
        guard case .loaded(let medications) = self else { return nil }
        return medications
    }
}

@MainActor
struct MedicationListViewModelTests {
    @Test func loadsMedicationsSortedByCreationDate() async throws {
        let older = try makeMedication(name: "Older", createdDate: .now.addingTimeInterval(-60))
        let newer = try makeMedication(name: "Newer")
        let sut = makeSUT(repository: MockMedicationRepository(medications: [newer, older]))
        
        await sut.load()
        
        #expect(sut.state.medications?.map { $0.name } == ["Older", "Newer"])
    }
    
    @Test func togglingFlipsActiveState() async throws {
        let medication = try makeMedication(isActive: true)
        let sut = makeSUT(repository: MockMedicationRepository(medications: [medication]))
        
        await sut.toggle(medication)
        
        #expect(sut.state.medications?.first?.isActive == false)
    }
    
    @Test func deletingRemovesMedication() async throws {
        let medication = try makeMedication()
        let sut = makeSUT(repository: MockMedicationRepository(medications: [medication]))
        
        await sut.delete(medication)
        
        #expect(sut.state == .empty)
    }
    
    @Test func reportsFailureStateWhenLoadingFails() async throws {
        let sut = makeSUT(repository: MockMedicationRepository(fetchAllFails: true))
        
        await sut.load()
        
        #expect(sut.state == .failure(message: "Something went wrong. Please try again."))
        #expect(sut.errorMessage == nil)
    }
    
    @Test func keepsLoadedContentVisibleWhileRefreshing() async throws {
        let medication = try makeMedication()
        let repository = MockMedicationRepository(medications: [medication])
        let sut = makeSUT(repository: repository)
        
        await sut.load()
        
        await repository.setFetchAllHook {
            #expect(await sut.state.medications?.count == 1)
        }
        
        await sut.load()
    }
    
    @Test func showsLoadingBeforeFirstLoadCompletes() async throws {
        let repository = MockMedicationRepository()
        let sut = makeSUT(repository: repository)
        
        await repository.setFetchAllHook {
            #expect(await sut.state == .loading)
        }
        
        await sut.load()
        
        #expect(sut.state == .empty)
    }
    
    @Test func flagsUnavailableNotificationsWhenAuthorizationRefused() async throws {
        let sut = makeSUT(authorizer: MockNotificationAuthorizer(isAuthorized: false))
        
        await sut.start()
        
        #expect(sut.notificationsUnavailable)
    }
    
    @Test func flagsUnavailableNotificationsWhenSchedulingDenied() async throws {
        let medication = try makeMedication(isActive: false)
        let sut = makeSUT(
            repository: MockMedicationRepository(medications: [medication]),
            scheduler: MockReminderScheduler(failsWithAuthorizationDenied: true)
        )
        
        await sut.toggle(medication)
        
        #expect(sut.notificationsUnavailable)
        #expect(sut.errorMessage == nil)
    }
    
    @Test func schedulesRemindersOnStartWhenAlreadyAuthorized() async throws {
        let medication = try makeMedication()
        let scheduler = MockReminderScheduler()
        let sut = makeSUT(
            repository: MockMedicationRepository(medications: [medication]),
            scheduler: scheduler
        )
        
        await sut.start()
        
        #expect(sut.notificationsUnavailable == false)
        #expect(await scheduler.scheduledIds == [medication.id])
    }
    
    @Test func schedulesRemindersWhenAccessIsGrantedLater() async throws {
        let medication = try makeMedication()
        let scheduler = MockReminderScheduler()
        let authorizer = MockNotificationAuthorizer(isAuthorized: false)
        let sut = makeSUT(
            repository: MockMedicationRepository(medications: [medication]),
            scheduler: scheduler,
            authorizer: authorizer
        )
        
        await sut.start()
        
        #expect(sut.notificationsUnavailable)
        #expect(await scheduler.scheduledIds.isEmpty)
        
        await authorizer.setAuthorized(true)
        await sut.refreshNotificationAccess()
        
        #expect(sut.notificationsUnavailable == false)
        #expect(await scheduler.scheduledIds == [medication.id])
    }
    
    @Test func keepsBannerWhenAccessIsStillDenied() async throws {
        let medication = try makeMedication()
        let scheduler = MockReminderScheduler()
        let sut = makeSUT(
            repository: MockMedicationRepository(medications: [medication]),
            scheduler: scheduler,
            authorizer: MockNotificationAuthorizer(isAuthorized: false)
        )
        
        await sut.start()
        await sut.refreshNotificationAccess()
        
        #expect(sut.notificationsUnavailable)
        #expect(await scheduler.scheduledIds.isEmpty)
    }
    
    private func makeSUT(
        repository: MockMedicationRepository = MockMedicationRepository(),
        scheduler: MockReminderScheduler = MockReminderScheduler(),
        authorizer: MockNotificationAuthorizer = MockNotificationAuthorizer(isAuthorized: true)
    ) -> MedicationListViewModel {
        let saveMedication = SaveMedicationUseCase(
            repository: repository,
            scheduler: scheduler
        )
        
        return MedicationListViewModel(
            repository: repository,
            saveMedication: saveMedication,
            deleteMedication: DeleteMedicationUseCase(
                repository: repository,
                scheduler: scheduler
            ),
            toggleMedicationActive: ToggleMedicationActiveUseCase(saveMedication: saveMedication),
            syncReminder: SyncReminderUseCase(
                repository: repository,
                scheduler: scheduler
            ),
            authorizer: authorizer
        )
    }
}
