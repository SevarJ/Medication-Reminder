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
            .navigationTitle("Medications")
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
            "Something Went Wrong",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
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
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                VStack(alignment: .leading, spacing: 0) {
                    SectionHeader(title: "All Medications")
                    
                    CardSection {
                        ForEach(Array(medications.enumerated()), id: \.element.id) { index, medication in
                            if index > 0 {
                                RowSeparator(leadingInset: Spacing.lg)
                            }
                            
                            Button {
                                editorViewModel = viewModel.makeEditorViewModel(for: medication)
                            } label: {
                                MedicationRow(medication: medication)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(medication.isActive ? "Pause Reminders" : "Resume Reminders") {
                                    Task { await viewModel.toggle(medication) }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.bottom, Spacing.lg)
        }
    }
    
    private var notificationBanner: some View {
        CardSection {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Notifications Are Off")
                    .font(Font.theme.rowTitle)
                    .foregroundStyle(Color.theme.textPrimary)
                
                Text("Reminders cannot be delivered until notifications are enabled in Settings.")
                    .font(Font.theme.rowSubtitle)
                    .foregroundStyle(Color.theme.textSecondary)
                
                Button("Open Settings") {
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    openURL(url)
                }
                .font(Font.theme.rowSubtitle)
                .tint(Color.theme.accent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.lg)
        }
    }
    
    private func failureState(message: String) -> some View {
        VStack(spacing: Spacing.md) {
            IconTile(
                systemName: "exclamationmark.triangle.fill",
                foreground: Color.theme.danger,
                background: Color.theme.surface
            )
            
            Text("Could Not Load Medications")
                .font(Font.theme.rowTitle)
                .foregroundStyle(Color.theme.textPrimary)
            
            Text(message)
                .font(Font.theme.rowSubtitle)
                .foregroundStyle(Color.theme.textSecondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
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
            
            Text("No Medications Yet")
                .font(Font.theme.rowTitle)
                .foregroundStyle(Color.theme.textPrimary)
            
            Text("Add your first medication to start receiving reminders.")
                .font(Font.theme.rowSubtitle)
                .foregroundStyle(Color.theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(Spacing.xxl)
    }
}
