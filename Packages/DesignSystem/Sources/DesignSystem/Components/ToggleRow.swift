//
//  ToggleRow.swift
//  DesignSystem
//
//  Created by Sevar Jafarli on 24.09.26.
//

import SwiftUI

public struct ToggleRow: View {
    private let title: String
    
    @Binding private var isOn: Bool
    
    public init(title: String, isOn: Binding<Bool>) {
        self.title = title
        self._isOn = isOn
    }
    
    public var body: some View {
        HStack {
            Text(title)
                .font(Font.theme.rowTitle)
                .foregroundStyle(Color.theme.textPrimary)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color.theme.accent)
        }
        .padding(Spacing.lg)
        .contentShape(Rectangle())
        .onTapGesture {
            isOn.toggle()
        }
    }
}
