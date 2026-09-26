//
//  DoseReminderView.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 24.09.26.
//

import AppLocalization
import DesignSystem
import Domain
import SwiftUI

public struct DoseReminderView: View {
    @State private var viewModel: DoseReminderViewModel
    
    private let onClose: () -> Void
    
    public init(viewModel: DoseReminderViewModel, onClose: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onClose = onClose
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            closeButton
            
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(Spacing.xl)
        .background(Color.theme.background)
        .alert(
            CommonText.errorTitle,
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button(CommonText.ok, role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .sensoryFeedback(.success, trigger: viewModel.isFinished) { _, finished in
            finished && isTaken
        }
        .task {
            await viewModel.load()
        }
        .task(id: viewModel.isFinished) {
            guard viewModel.isFinished else { return }
            
            if isTaken {
                try? await Task.sleep(for: .milliseconds(900))
            }
            
            onClose()
        }
    }
    
    private var closeButton: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(.body, weight: .semibold))
                    .foregroundStyle(Color.theme.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(Color.theme.surface, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.Reminder.close)
            
            Spacer()
        }
    }
    
    @ViewBuilder private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
        case .loaded(let dose):
            details(for: dose)
        case .failure(let message):
            failureState(message: message)
        }
    }
    
    private var isTaken: Bool {
        guard case .loaded(let dose) = viewModel.state else { return false }
        
        return dose.log?.status == .taken
    }
    
    private func details(for dose: ScheduledDose) -> some View {
        VStack(spacing: Spacing.xl) {
            Spacer()
            
            Image(systemName: isTaken ? "checkmark" : "pills.fill")
                .font(.system(size: 52, weight: .semibold))
                .foregroundStyle(isTaken ? Color.theme.surface : Color.theme.accent)
                .contentTransition(.symbolEffect(.replace))
                .frame(width: 128, height: 128)
                .background(isTaken ? Color.theme.accent : Color.theme.accentTint, in: Circle())
                .animation(.spring(duration: 0.4), value: isTaken)
            
            VStack(spacing: Spacing.sm) {
                Text(L10n.Reminder.eyebrow)
                    .font(Font.theme.rowSubtitle)
                    .foregroundStyle(Color.theme.textSecondary)
                
                Text(dose.scheduledDate.timeText)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.theme.textPrimary)
                
                Text(dose.medication.name)
                    .font(.system(.title2, weight: .bold))
                    .foregroundStyle(Color.theme.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(dose.medication.dosage.displayText)
                    .font(.system(.title3))
                    .foregroundStyle(Color.theme.textSecondary)
                
                status(of: dose)
                    .padding(.top, Spacing.sm)
            }
            
            Spacer()
            
            actions(for: dose)
        }
    }
    
    @ViewBuilder private func status(of dose: ScheduledDose) -> some View {
        switch dose.log?.status {
        case .taken:
            if let recordedAt = dose.log?.recordedAt {
                Badge(title: L10n.Today.takenAt(recordedAt.timeText))
            }
        case .skipped:
            Badge(
                title: L10n.Today.skipped,
                foreground: Color.theme.textSecondary,
                background: Color.theme.separator
            )
        case nil:
            EmptyView()
        }
    }
    
    @ViewBuilder private func actions(for dose: ScheduledDose) -> some View {
        if !isTaken {
            VStack(spacing: Spacing.md) {
                Button {
                    Task { await viewModel.take() }
                } label: {
                    Label(L10n.Reminder.take, systemImage: "checkmark")
                        .font(.system(.title3, weight: .semibold))
                        .foregroundStyle(Color.theme.surface)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.lg)
                        .background(Color.theme.accent, in: RoundedRectangle(cornerRadius: CornerRadius.card))
                }
                .buttonStyle(.plain)
                
                Button {
                    Task { await viewModel.snooze() }
                } label: {
                    Text(L10n.Reminder.snooze(minutes: viewModel.snoozeMinutes))
                        .font(Font.theme.rowTitle)
                        .foregroundStyle(Color.theme.accent)
                        .padding(.vertical, Spacing.sm)
                }
                .buttonStyle(.plain)
            }
            .disabled(viewModel.isFinished)
        }
    }
    
    private func failureState(message: String) -> some View {
        VStack(spacing: Spacing.md) {
            IconTile(
                systemName: "exclamationmark.triangle.fill",
                foreground: Color.theme.danger,
                background: Color.theme.surface
            )
            
            Text(L10n.Reminder.loadFailedTitle)
                .font(Font.theme.rowTitle)
                .foregroundStyle(Color.theme.textPrimary)
            
            Text(message)
                .font(Font.theme.rowSubtitle)
                .foregroundStyle(Color.theme.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
}
