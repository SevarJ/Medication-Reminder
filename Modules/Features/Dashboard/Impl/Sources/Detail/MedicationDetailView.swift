//
//  MedicationDetailView.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 05.10.26.
//

import AppFormatters
import AppLocalization
import DesignSystem
import Domain
import SwiftUI

struct MedicationDetailView: View {
    @State private var viewModel: MedicationDetailViewModel
    @State private var editorViewModel: MedicationEditorViewModel?
    @State private var isConfirmingDelete = false
    
    @Environment(\.dismiss) private var dismiss
    
    private let onChange: () -> Void
    
    init(viewModel: MedicationDetailViewModel, onChange: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onChange = onChange
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                summaryCard
                historyCard
                notesCard
                actions
            }
            .padding(.vertical, Spacing.lg)
        }
        .background(Color.theme.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(L10n.Detail.edit) {
                    editorViewModel = viewModel.makeEditorViewModel()
                }
                .tint(Color.theme.accentText)
            }
        }
        .sheet(item: $editorViewModel) { editor in
            MedicationEditorView(
                viewModel: editor,
                onFinish: { saved in
                    editorViewModel = nil
                    
                    if saved {
                        Task {
                            await viewModel.load()
                            onChange()
                        }
                    }
                }
            )
        }
        .confirmationDialog(
            L10n.List.deleteTitle(viewModel.medication.name),
            isPresented: $isConfirmingDelete,
            titleVisibility: .visible
        ) {
            Button(L10n.Editor.deleteMedication, role: .destructive) {
                Task {
                    if await viewModel.delete() {
                        onChange()
                        dismiss()
                    }
                }
            }
            
            Button(CommonText.cancel, role: .cancel) {}
        } message: {
            Text(L10n.List.deleteMessage)
        }
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
        .task {
            await viewModel.load()
        }
    }
    
    private var summaryCard: some View {
        let medication = viewModel.medication
        
        return VStack(alignment: .leading, spacing: Spacing.xl) {
            HStack(alignment: .top, spacing: Spacing.lg) {
                if medication.photo != nil {
                    MedicationAvatar(photo: medication.photo, size: 64)
                }
                
                heroTitle(medication)
            }
            
            if medication.stock != nil {
                stockLine(medication)
            }
            
            AdaptiveStack(spacing: Spacing.lg) {
                stat(title: L10n.Detail.taken, count: viewModel.takenCount)
                stat(title: L10n.Today.skipped, count: viewModel.skippedCount)
                stat(title: L10n.Today.missed, count: viewModel.missedCount)
            }
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .heroCardBackground()
        .padding(.horizontal, Spacing.lg)
    }
    
    private func heroTitle(_ medication: Medication) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: Spacing.md) {
                Text(medication.name)
                    .font(.system(.title2, weight: .bold))
                    .foregroundStyle(Color.theme.onHero)
                    .accessibilityAddTraits(.isHeader)
                
                Spacer(minLength: 0)
                
                if !medication.isActive {
                    Text(L10n.List.paused)
                        .font(Font.theme.badge)
                        .foregroundStyle(Color.theme.onHero)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.xs + 1)
                        .background(Color.theme.onHero.opacity(0.18), in: Capsule())
                }
            }
            
            Text("\(medication.dosage.displayText) · \(medication.schedule.recurrence.displayText)")
                .font(Font.theme.rowSubtitle)
                .foregroundStyle(Color.theme.onHero.opacity(0.85))
            
            Text(medication.schedule.times.sorted().map(\.displayText).joined(separator: "  ·  "))
                .font(Font.theme.time)
                .foregroundStyle(Color.theme.onHero)
                .padding(.top, Spacing.sm)
        }
    }
    
    /// What is left of the pack. Turns into a warning with a week or less to go.
    private func stockLine(_ medication: Medication) -> some View {
        let stock = medication.stock ?? 0
        let days = medication.daysOfStockLeft
        let isLow = stock <= 0 || (days ?? .max) <= 7
        let text: String
        
        if stock <= 0 {
            text = L10n.Form.stockOut
        }
        else {
            let left = L10n.Form.stockLeft(Dosage(amount: stock, unit: medication.dosage.unit).displayText)
            text = days.map { "\(left) · \(L10n.Form.daysLeft($0))" } ?? left
        }
        
        return Label(text, systemImage: isLow ? "exclamationmark.triangle.fill" : "shippingbox.fill")
            .font(.system(.subheadline, weight: .semibold))
            .foregroundStyle(Color.theme.onHero)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(Color.theme.onHero.opacity(isLow ? 0.28 : 0.18), in: Capsule())
    }
    
    private func stat(title: String, count: Int) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(count.formatted(.number.locale(AppLanguage.current.locale)))
                .font(Font.theme.display)
                .foregroundStyle(Color.theme.onHero)
            
            Text(title)
                .font(Font.theme.rowSubtitle)
                .foregroundStyle(Color.theme.onHero.opacity(0.85))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
    
    private var historyCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text(L10n.Detail.history)
                    .font(Font.theme.sectionTitle)
                    .foregroundStyle(Color.theme.textPrimary)
                
                Spacer(minLength: Spacing.md)
                
                if !viewModel.dueDoses.isEmpty {
                    Text(viewModel.adherence.formatted(.percent.precision(.fractionLength(0)).locale(AppLanguage.current.locale)))
                        .font(.system(.title3, design: .rounded, weight: .bold).monospacedDigit())
                        .foregroundStyle(Color.theme.accentText)
                }
            }
            
            if viewModel.dueDoses.isEmpty {
                Text(L10n.Detail.noHistory)
                    .font(Font.theme.rowSubtitle)
                    .foregroundStyle(Color.theme.textSecondary)
            }
            else {
                HStack(spacing: 0) {
                    ForEach(viewModel.history.reversed()) { day in
                        dayCell(day)
                    }
                }
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            }
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
        .padding(.horizontal, Spacing.lg)
    }
    
    private func dayCell(_ day: DoseDaySummary) -> some View {
        let locale = AppLanguage.current.locale
        
        return VStack(spacing: Spacing.xs) {
            Text(day.date.formatted(.dateTime.weekday(.abbreviated).locale(locale)))
                .font(Font.theme.caption)
                .foregroundStyle(Color.theme.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            ZStack {
                if day.doses.isEmpty {
                    Circle()
                        .stroke(Color.theme.fill, lineWidth: 3)
                        .padding(1.5)
                }
                else {
                    ProgressRing(
                        progress: day.adherence,
                        lineWidth: 3,
                        tint: Color.theme.accent,
                        track: Color.theme.accentTint
                    )
                }
                
                Text(day.date.formatted(.dateTime.day().locale(locale)))
                    .font(.system(.subheadline, weight: .semibold))
                    .foregroundStyle(Color.theme.textPrimary)
            }
            .frame(width: 44, height: 44)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(day.date.formatted(.dateTime.weekday(.wide).day().month(.wide).locale(locale)))\(day.doses.isEmpty ? "" : ", \(day.takenCount)/\(day.doses.count)")"
        )
    }
    
    @ViewBuilder private var notesCard: some View {
        if let notes = viewModel.medication.notes {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(L10n.Form.notesTitle)
                    .font(Font.theme.sectionTitle)
                    .foregroundStyle(Color.theme.textPrimary)
                
                Text(notes)
                    .font(Font.theme.rowSubtitle)
                    .foregroundStyle(Color.theme.textSecondary)
            }
            .padding(Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardSurface()
            .padding(.horizontal, Spacing.lg)
        }
    }
    
    private var actions: some View {
        VStack(spacing: Spacing.md) {
            Button {
                Task {
                    await viewModel.toggle()
                    onChange()
                }
            } label: {
                Label(
                    viewModel.medication.isActive ? L10n.List.pauseReminders : L10n.List.resumeReminders,
                    systemImage: viewModel.medication.isActive ? "pause.fill" : "play.fill"
                )
            }
            .buttonStyle(.secondaryAction)
            .padding(.horizontal, Spacing.lg)
            
            CardSection {
                DestructiveRow(title: L10n.Editor.deleteMedication) {
                    isConfirmingDelete = true
                }
            }
        }
    }
}
