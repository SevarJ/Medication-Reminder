//
//  MedicationEditorView.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 12.09.26.
//

import DesignSystem
import Domain
import SwiftUI

struct MedicationEditorView: View {
    @Bindable var viewModel: MedicationEditorViewModel
    
    let onFinish: (Bool) -> Void
    let onDelete: (() -> Void)?
    
    @State private var isConfirmingDelete = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    detailsSection
                    remindersSection
                    statusSection
                    
                    if onDelete != nil {
                        CardSection {
                            DestructiveRow(title: "Delete Medication") {
                                isConfirmingDelete = true
                            }
                        }
                    }
                }
                .padding(.vertical, Spacing.lg)
            }
            .background(Color.theme.background)
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        onFinish(false)
                    }
                    .tint(Color.theme.accent)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        Task {
                            if await viewModel.save() {
                                onFinish(true)
                            }
                        }
                    }
                    .tint(Color.theme.accent)
                    .disabled(viewModel.isSaving)
                }
            }
            .confirmationDialog(
                "Delete this medication?",
                isPresented: $isConfirmingDelete,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    onDelete?()
                }
                
                Button("Cancel", role: .cancel) {}
            }
            .alert(
                "Check Your Input",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.errorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "Details")
            
            CardSection {
                TextField("Medication name", text: $viewModel.name)
                    .font(Font.theme.rowTitle)
                    .foregroundStyle(Color.theme.textPrimary)
                    .padding(Spacing.lg)
                
                RowSeparator()
                
                HStack(spacing: Spacing.md) {
                    Text("Dosage")
                        .font(Font.theme.rowTitle)
                        .foregroundStyle(Color.theme.textPrimary)
                    
                    Spacer()
                    
                    TextField("Amount", text: $viewModel.amountText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .font(Font.theme.rowSubtitle)
                        .foregroundStyle(Color.theme.textSecondary)
                        .frame(maxWidth: 80)
                }
                .padding(Spacing.lg)
                
                RowSeparator()
                
                Picker("Unit", selection: $viewModel.unit) {
                    ForEach(DosageUnit.allCases, id: \.self) { unit in
                        Text(unit.displayText).tag(unit)
                    }
                }
                .pickerStyle(.segmented)
                .padding(Spacing.lg)
            }
        }
    }
    
    private var remindersSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "Reminders")
            
            CardSection {
                ForEach(viewModel.times) { time in
                    if time.id != viewModel.times.first?.id {
                        RowSeparator()
                    }
                    
                    HStack(spacing: Spacing.md) {
                        DatePicker(
                            "",
                            selection: Binding(
                                get: { time.date },
                                set: { viewModel.updateTime(id: time.id, to: $0) }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                        
                        Spacer()
                        
                        if viewModel.times.count > 1 {
                            Button {
                                viewModel.removeTime(id: time.id)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(Color.theme.danger)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(Spacing.lg)
                }
                
                RowSeparator()
                
                Button {
                    viewModel.addTime()
                } label: {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Time")
                    }
                    .font(Font.theme.rowTitle)
                    .foregroundStyle(Color.theme.accent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Spacing.lg)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "Status")
            
            CardSection {
                Toggle(isOn: $viewModel.isActive) {
                    Text("Reminders Enabled")
                        .font(Font.theme.rowTitle)
                        .foregroundStyle(Color.theme.textPrimary)
                }
                .tint(Color.theme.accent)
                .padding(Spacing.lg)
            }
        }
    }
}
