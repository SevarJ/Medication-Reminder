//
//  ProfileView.swift
//  SettingsImpl
//
//  Created by Sevar Jafarli on 01.10.26.
//

import AppLocalization
import DesignSystem
import Domain
import SwiftUI

struct ProfileView: View {
    let account: UserAccount
    let onSignOut: () -> Void
    
    @State private var isConfirmingSignOut = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                AccountAvatar(photoURL: account.photoURL, size: 112)
                    .padding(.top, Spacing.lg)
                
                if account.displayName != nil || account.email != nil {
                    CardSection {
                        if let displayName = account.displayName {
                            infoRow(title: L10n.Settings.profileName, value: displayName)
                        }
                        
                        if account.displayName != nil, account.email != nil {
                            RowSeparator()
                        }
                        
                        if let email = account.email {
                            infoRow(title: L10n.Settings.profileEmail, value: email)
                        }
                    }
                }
                
                CardSection {
                    DestructiveRow(title: L10n.Settings.signOut) {
                        isConfirmingSignOut = true
                    }
                }
            }
            .padding(.vertical, Spacing.lg)
        }
        .background(Color.theme.background)
        .navigationTitle(L10n.Settings.account)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(L10n.Settings.signOutConfirmation, isPresented: $isConfirmingSignOut, titleVisibility: .visible) {
            Button(L10n.Settings.signOut, role: .destructive, action: onSignOut)
            
            Button(CommonText.cancel, role: .cancel) {}
        }
    }
    
    private func infoRow(title: String, value: String) -> some View {
        AdaptiveStack {
            Text(title)
                .font(Font.theme.rowTitle)
                .foregroundStyle(Color.theme.textPrimary)
            
            Spacer(minLength: 0)
            
            Text(value)
                .font(Font.theme.rowSubtitle)
                .foregroundStyle(Color.theme.textSecondary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding(Spacing.lg)
    }
}
