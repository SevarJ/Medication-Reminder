//
//  MedicationEditorView.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 12.09.26.
//

import AppFormatters
import AppLocalization
import DesignSystem
import Domain
import SwiftUI

/// Adding walks through the steps one by one. Editing shows a summary and opens only the step to change.
struct MedicationEditorView: View {
    @Bindable var viewModel: MedicationEditorViewModel
    
    let onFinish: (Bool) -> Void
    
    var body: some View {
        if viewModel.isEditing {
            MedicationEditPage(viewModel: viewModel, onFinish: onFinish)
        }
        else {
            MedicationWizardView(viewModel: viewModel, onFinish: onFinish)
        }
    }
}

extension View {
    func editorErrorAlert(_ viewModel: MedicationEditorViewModel) -> some View {
        alert(
            L10n.Editor.invalidInputTitle,
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button(CommonText.ok, role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

// MARK: - Adding

private struct MedicationWizardView: View {
    @Bindable var viewModel: MedicationEditorViewModel
    
    let onFinish: (Bool) -> Void
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    header
                    
                    EditorStepContent(step: viewModel.step, viewModel: viewModel)
                        .id(viewModel.step)
                        .transition(.opacity)
                }
                .padding(.vertical, Spacing.lg)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.theme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(CommonText.cancel, systemImage: "xmark") {
                        onFinish(false)
                    }
                    .labelStyle(.iconOnly)
                    .tint(Color.theme.accentText)
                }
            }
            .safeAreaInset(edge: .bottom) {
                bottomBar
            }
            .editorErrorAlert(viewModel)
        }
        .animation(.snappy, value: viewModel.step)
    }
    
    private var header: some View {
        let total = EditorStep.allCases.count
        let current = viewModel.step.rawValue + 1
        
        return VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.xs + 2) {
                ForEach(EditorStep.allCases) { step in
                    Capsule()
                        .fill(step.rawValue < current ? Color.theme.hero : Color.theme.fill)
                        .frame(height: 5)
                }
            }
            .accessibilityHidden(true)
            
            Text(L10n.Form.stepOf(current, total))
                .font(Font.theme.rowSubtitle)
                .foregroundStyle(Color.theme.textSecondary)
            
            Text(viewModel.step.question)
                .font(Font.theme.screenTitle)
                .foregroundStyle(Color.theme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
        }
        .padding(.horizontal, Spacing.xl)
    }
    
    private var bottomBar: some View {
        HStack(spacing: Spacing.md) {
            if !viewModel.isFirstStep {
                Button(L10n.Form.back) {
                    viewModel.back()
                }
                .buttonStyle(.secondaryAction)
                .frame(maxWidth: 140)
            }
            
            Button(viewModel.isLastStep ? CommonText.save : L10n.Form.next) {
                if viewModel.isLastStep {
                    Task {
                        if await viewModel.save() {
                            onFinish(true)
                        }
                    }
                }
                else {
                    viewModel.next()
                }
            }
            .buttonStyle(.primaryAction)
            .disabled(viewModel.isSaving)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.md)
        .padding(.bottom, Spacing.sm)
        .background(Color.theme.background)
    }
}

// MARK: - Editing

private struct MedicationEditPage: View {
    @Bindable var viewModel: MedicationEditorViewModel
    
    let onFinish: (Bool) -> Void
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    preview
                    stepRows
                }
                .padding(.vertical, Spacing.lg)
            }
            .background(Color.theme.background)
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: EditorStep.self) { step in
                ScrollView {
                    EditorStepContent(step: step, viewModel: viewModel)
                        .padding(.vertical, Spacing.lg)
                }
                .scrollDismissesKeyboard(.interactively)
                .background(Color.theme.background)
                .navigationTitle(step.title)
                .navigationBarTitleDisplayMode(.inline)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(CommonText.cancel, systemImage: "xmark") {
                        onFinish(false)
                    }
                    .labelStyle(.iconOnly)
                    .tint(Color.theme.accentText)
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button(CommonText.save) {
                    Task {
                        if await viewModel.save() {
                            onFinish(true)
                        }
                    }
                }
                .buttonStyle(.primaryAction)
                .disabled(viewModel.isSaving)
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.sm)
                .background(Color.theme.background)
            }
            .editorErrorAlert(viewModel)
        }
    }
    
    /// Shows the medication as it will look once saved.
    private var preview: some View {
        HStack(alignment: .center, spacing: Spacing.lg) {
            if viewModel.photo != nil {
                MedicationAvatar(photo: viewModel.photo, size: 64)
            }
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(viewModel.name.isEmpty ? L10n.Editor.namePlaceholder : viewModel.name)
                    .font(.system(.title2, weight: .bold))
                    .foregroundStyle(Color.theme.onHero.opacity(viewModel.name.isEmpty ? 0.6 : 1))
                
                Text("\(viewModel.dosage?.displayText ?? viewModel.amountText) · \(viewModel.recurrence.displayText)")
                    .font(Font.theme.rowSubtitle)
                    .foregroundStyle(Color.theme.onHero.opacity(0.85))
                
                Text(viewModel.times.sorted().map(\.displayText).joined(separator: "  ·  "))
                    .font(Font.theme.time)
                    .foregroundStyle(Color.theme.onHero)
                    .padding(.top, Spacing.xs)
            }
            
            Spacer(minLength: 0)
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .heroCardBackground()
        .padding(.horizontal, Spacing.lg)
        .accessibilityElement(children: .combine)
    }
    
    private var stepRows: some View {
        CardSection {
            ForEach(EditorStep.allCases) { step in
                if step != EditorStep.allCases.first {
                    RowSeparator(leadingInset: Spacing.lg + 44 + Spacing.md)
                }
                
                NavigationLink(value: step) {
                    row(for: step)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private func row(for step: EditorStep) -> some View {
        HStack(spacing: Spacing.md) {
            IconTile(
                systemName: step.systemImage,
                foreground: Color.theme.accentText,
                background: Color.theme.accentTint,
                size: 44
            )
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(step.title)
                    .font(Font.theme.rowTitle)
                    .foregroundStyle(Color.theme.textPrimary)
                
                Text(viewModel.summary(of: step))
                    .font(Font.theme.rowSubtitle)
                    .foregroundStyle(Color.theme.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer(minLength: Spacing.sm)
            
            Image(systemName: "chevron.right")
                .font(.system(.footnote, weight: .semibold))
                .foregroundStyle(Color.theme.textSecondary.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, Spacing.md)
        .padding(.horizontal, Spacing.lg)
        .frame(minHeight: 72)
        .contentShape(Rectangle())
    }
}
