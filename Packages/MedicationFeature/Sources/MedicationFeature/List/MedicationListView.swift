//
//  MedicationListView.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 12.09.26.
//

import DesignSystem
import Domain
import SwiftUI
import UIKit

public struct MedicationListView: View {
    @State private var viewModel: MedicationListViewModel
    @State private var editorViewModel: MedicationEditorViewModel?
    @State private var pendingDeletion: Medication?
    
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    
    public init(viewModel: MedicationListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.lg) {
                if viewModel.notificationsUnavailable {
                    notificationBanner
                        .padding(.top, Spacing.sm)
                }
                
                contentView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(Color.theme.background)
            .navigationTitle(L10n.List.title)
            .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            editorViewModel = viewModel.makeEditorViewModel(for: nil)
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(.body, weight: .semibold))
                    }
                    .tint(Color.theme.accent)
                }
            }
        }
       
        .sheet(item: $editorViewModel) { editor in
            MedicationEditorView(
                viewModel: editor,
                onFinish: { saved in
                    editorViewModel = nil
                    
                    if saved {
                        Task { await viewModel.load() }
                    }
                },
                onDelete: editor.medication.map { medication in
                    {
                        editorViewModel = nil
                        Task { await viewModel.delete(medication) }
                    }
                }
            )
        }
        .alert(
            L10n.Common.errorTitle,
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button(L10n.Common.ok, role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .task {
            await viewModel.start()
        }
        .onChange(of: scenePhase) { _, newValue in
            if newValue == .active {
                Task {
                    await viewModel.refreshNotificationAccess()
                }
            }
        }
    }
    
    @ViewBuilder private var contentView: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
        case .loaded(let medications):
            content(medications: medications)
        case .empty:
            emptyState
        case .failure(let message):
            failureState(message: message)
        }
    }
    
    private func content(medications: [Medication]) -> some View {
        List {
            Section {
                ForEach(medications) { medication in
                    Button {
                        editorViewModel = viewModel.makeEditorViewModel(for: medication)
                    } label: {
                        MedicationRow(medication: medication)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(medication.isActive ? L10n.List.pauseReminders : L10n.List.resumeReminders) {
                            Task { await viewModel.toggle(medication) }
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button {
                            pendingDeletion = medication
                        } label: {
                            Label(L10n.Common.delete, systemImage: "trash")
                        }
                        .tint(Color.theme.danger)
                    }
                    .confirmationDialog(
                        L10n.List.deleteTitle(medication.name),
                        isPresented: Binding(
                            get: { pendingDeletion?.id == medication.id },
                            set: { if !$0 { pendingDeletion = nil } }
                        ),
                        titleVisibility: .visible
                    ) {
                        Button(L10n.Editor.deleteMedication, role: .destructive) {
                            Task { await viewModel.delete(medication) }
                        }
                        
                        Button(L10n.Common.cancel, role: .cancel) {}
                    } message: {
                        Text(L10n.List.deleteMessage)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.theme.surface)
                    .listRowSeparatorTint(Color.theme.separator)
                }
            } header: {
                Text(L10n.List.allMedications)
                    .font(Font.theme.rowSubtitle)
                    .foregroundStyle(Color.theme.textSecondary)
                    .textCase(nil)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .animation(.default, value: medications)
    }
    
    private var notificationBanner: some View {
        CardSection {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(L10n.Banner.title)
                    .font(Font.theme.rowTitle)
                    .foregroundStyle(Color.theme.textPrimary)
                
                Text(bannerMessage)
                    .font(Font.theme.rowSubtitle)
                    .foregroundStyle(Color.theme.textSecondary)
                
                Button(bannerActionTitle, action: performBannerAction)
                    .font(Font.theme.rowSubtitle)
                    .tint(Color.theme.accent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.lg)
        }
    }
    
    private var canRequestNotifications: Bool {
        viewModel.notificationAccess == .notDetermined
    }
    
    private var bannerMessage: String {
        canRequestNotifications
            ? L10n.Banner.requestMessage
            : L10n.Banner.settingsMessage
    }
    
    private var bannerActionTitle: String {
        canRequestNotifications ? L10n.Banner.turnOn : L10n.Banner.openSettings
    }
    
    private func performBannerAction() {
        guard !canRequestNotifications else {
            Task { await viewModel.enableNotifications() }
            return
        }
        
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        
        openURL(url)
    }
    
    private func failureState(message: String) -> some View {
        VStack(spacing: Spacing.md) {
            IconTile(
                systemName: "exclamationmark.triangle.fill",
                foreground: Color.theme.danger,
                background: Color.theme.surface
            )
            
            Text(L10n.List.loadFailedTitle)
                .font(Font.theme.rowTitle)
                .foregroundStyle(Color.theme.textPrimary)
            
            Text(message)
                .font(Font.theme.rowSubtitle)
                .foregroundStyle(Color.theme.textSecondary)
                .multilineTextAlignment(.center)
            
            Button(L10n.Common.tryAgain) {
                Task { await viewModel.load() }
            }
            .font(Font.theme.rowTitle)
            .tint(Color.theme.accent)
            .padding(.top, Spacing.sm)
        }
        .padding(Spacing.xxl)
    }
    
    private var emptyState: some View {
        VStack(spacing: Spacing.md) {
            IconTile(
                systemName: "pills.fill",
                foreground: Color.theme.accent,
                background: Color.theme.accentTint
            )
            
            Text(L10n.List.emptyTitle)
                .font(Font.theme.rowTitle)
                .foregroundStyle(Color.theme.textPrimary)
            
            Text(L10n.List.emptyMessage)
                .font(Font.theme.rowSubtitle)
                .foregroundStyle(Color.theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(Spacing.xxl)
    }
}
