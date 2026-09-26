//
//  NotificationPrimingModel.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 24.09.26.
//

import AppPreferences
import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class NotificationPrimingModel {
    public private(set) var isPresented = false
    
    private let authorizer: any NotificationAuthorizing
    private let syncReminder: SyncReminderUseCase
    private let preferences: AppPreferences
    
    public init(
        authorizer: any NotificationAuthorizing,
        syncReminder: SyncReminderUseCase,
        preferences: AppPreferences = AppPreferences()
    ) {
        self.authorizer = authorizer
        self.syncReminder = syncReminder
        self.preferences = preferences
    }
    
    public func evaluate() async {
        guard !preferences.hasShownNotificationPriming,
              await authorizer.access() == .notDetermined
        else {
            return
        }
        
        isPresented = true
    }
    
    public func allow() async {
        markPrompted()
        
        let isGranted = (try? await authorizer.requestAuthorization()) ?? false
        
        isPresented = false
        
        guard isGranted else { return }
        
        try? await syncReminder.execute()
    }
    
    public func dismiss() {
        markPrompted()
        isPresented = false
    }
    
    private func markPrompted() {
        preferences.markNotificationPrimingShown()
    }
}
