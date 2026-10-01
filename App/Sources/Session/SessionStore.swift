//
//  SessionStore.swift
//  Medora
//
//  Created by Sevar Jafarli on 01.10.26.
//

import Domain
import Observation

@MainActor
@Observable
final class SessionStore {
    enum State: Equatable {
        case loading
        case signedOut
        case signedIn(UserAccount)
    }
    
    private(set) var state: State = .loading
    /// Goes up each time the cache is refreshed from the server, which tells the screens to reload.
    private(set) var revision = 0
    
    private let authenticator: any AccountAuthenticating
    private let profiles: any UserProfileRepository
    private let refreshData: RefreshAccountDataUseCase
    private let clearLocalData: ClearLocalDataUseCase
    private var profileSave: Task<Void, Never>?
    private var refreshTask: Task<Void, Never>?
    
    init(
        authenticator: any AccountAuthenticating,
        profiles: any UserProfileRepository,
        refreshData: RefreshAccountDataUseCase,
        clearLocalData: ClearLocalDataUseCase
    ) {
        self.authenticator = authenticator
        self.profiles = profiles
        self.refreshData = refreshData
        self.clearLocalData = clearLocalData
    }
    
    /// Follows sign-ins and sign-outs for as long as the calling task lives.
    func observe() async {
        for await account in authenticator.accounts() {
            guard let account else {
                state = .signedOut
                await endSession()
                continue
            }
            
            if state == .signedOut {
                // A new sign-in starts from an empty cache, so the first screen waits for the account's data.
                state = .loading
                await startRefresh().value
            }
            else {
                // A returning session shows what the cache has straight away and catches up behind it.
                startRefresh()
            }
            
            state = .signedIn(account)
            saveProfile(of: account)
        }
    }
    
    /// Replaces the cache with the account's data on the server. Offline it does nothing and the cache stays as it is.
    func refresh() async {
        guard case .signedIn = state else { return }
        
        await startRefresh().value
    }
    
    @discardableResult
    private func startRefresh() -> Task<Void, Never> {
        if let refreshTask {
            return refreshTask
        }
        
        let task = Task {
            if (try? await refreshData.execute()) != nil {
                revision += 1
            }
            
            refreshTask = nil
        }
        
        refreshTask = task
        
        return task
    }
    
    /// Runs on every sign-out and on every launch that finds nobody signed in, so a wipe that failed is tried again.
    private func endSession() async {
        profileSave?.cancel()
        refreshTask?.cancel()
        
        // A refresh already in flight must finish first, or it could refill the cache after the wipe.
        await refreshTask?.value
        
        try? await clearLocalData.execute()
    }
    
    private func saveProfile(of account: UserAccount) {
        profileSave?.cancel()
        profileSave = Task { [profiles] in
            // Best effort: the profile is written again the next time a session starts.
            try? await profiles.save(account)
        }
    }
}
