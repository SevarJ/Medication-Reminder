//
//  DoseReminderView.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 24.09.26.
//

import AppFormatters
import AppLocalization
import DesignSystem
import Domain
import SwiftUI

struct DoseReminderView: View {
    @State private var viewModel: DoseReminderViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: DoseReminderViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
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
            
            dismiss()
        }
    }
    
    private var closeButton: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(.body, weight: .semibold))
                    .foregroundStyle(Color.theme.textPrimary)
                    .frame(width: Size.minTarget, height: Size.minTarget)
                    .background(Color.theme.fill, in: Circle())
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
                .font(.system(size: 48, weight: .semibold))
                .foregroundStyle(isTaken ? Color.theme.onHero : Color.theme.accentText)
                .contentTransition(.symbolEffect(.replace))
                .frame(width: 112, height: 112)
                .background(
                    isTaken ? Color.theme.hero : Color.theme.accentTint,
                    in: RoundedRectangle(cornerRadius: 32, style: .continuous)
                )
                .animation(.spring(duration: 0.4), value: isTaken)
                .accessibilityHidden(true)
            
            VStack(spacing: Spacing.sm) {
                Text(L10n.Reminder.eyebrow)
                    .font(.system(.subheadline, weight: .semibold))
                    .foregroundStyle(Color.theme.accentText)
                
                Text(dose.scheduledDate.timeText)
                    .font(.system(size: 64, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(Color.theme.textPrimary)
                
                Text(dose.medication.name)
                    .font(.system(.title2, weight: .semibold))
                    .foregroundStyle(Color.theme.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(dose.medication.dosage.displayText)
                    .font(.system(.title3))
                    .foregroundStyle(Color.theme.textSecondary)
                
                status(of: dose)
                    .padding(.top, Spacing.sm)
            }
            .accessibilityElement(children: .combine)
            
            Spacer()
            
            actions(for: dose)
        }
    }
    
    @ViewBuilder private func status(of dose: ScheduledDose) -> some View {
        switch dose.log?.status {
        case .taken:
            if let recordedAt = dose.log?.recordedAt {
                Badge(title: L10n.Today.takenAt(recordedAt.timeText), systemName: "checkmark")
            }
        case .skipped:
            Badge(
                title: L10n.Today.skipped,
                systemName: "forward.end.fill",
                foreground: Color.theme.info,
                background: Color.theme.infoTint
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
                }
                .buttonStyle(.primaryAction)
                
                Button {
                    Task { await viewModel.snooze() }
                } label: {
                    Label(L10n.Reminder.snooze(minutes: viewModel.snoozeMinutes), systemImage: "clock.arrow.circlepath")
                }
                .buttonStyle(.secondaryAction)
            }
            .disabled(viewModel.isFinished)
        }
    }
    
    private func failureState(message: String) -> some View {
        VStack(spacing: Spacing.md) {
            IconTile(
                systemName: "exclamationmark.triangle.fill",
                foreground: Color.theme.warning,
                background: Color.theme.warningTint,
                size: 56
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
