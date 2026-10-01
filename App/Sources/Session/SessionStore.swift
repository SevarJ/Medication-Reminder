//
//  SessionStore.swift
//  MedReminder
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
    
    private let authenticator: any AccountAuthenticating
    private let profiles: any UserProfileRepository
    private var profileSave: Task<Void, Never>?
    
    init(authenticator: any AccountAuthenticating, profiles: any UserProfileRepository) {
        self.authenticator = authenticator
        self.profiles = profiles
    }
    
    /// Follows sign-ins and sign-outs for as long as the calling task lives.
    func observe() async {
        for await account in authenticator.accounts() {
            guard let account else {
                state = .signedOut
                continue
            }
            
            state = .signedIn(account)
            saveProfile(of: account)
        }
    }
    
    private func saveProfile(of account: UserAccount) {
        profileSave?.cancel()
        profileSave = Task { [profiles] in
            // Best effort: the profile is written again the next time a session starts.
            try? await profiles.save(account)
        }
    }
}
