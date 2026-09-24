//
//  NotificationPrimingModel.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class NotificationPrimingModel {
    static let hasPromptedKey = "notificationPriming.hasPrompted"
    
    public private(set) var isPresented = false
    
    private let authorizer: any NotificationAuthorizing
    private let syncReminder: SyncReminderUseCase
    private let defaults: UserDefaults
    
    public init(
        authorizer: any NotificationAuthorizing,
        syncReminder: SyncReminderUseCase,
        defaults: UserDefaults = .standard
    ) {
        self.authorizer = authorizer
        self.syncReminder = syncReminder
        self.defaults = defaults
    }
    
    public func evaluate() async {
        guard !defaults.bool(forKey: Self.hasPromptedKey),
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
        defaults.set(true, forKey: Self.hasPromptedKey)
    }
}
