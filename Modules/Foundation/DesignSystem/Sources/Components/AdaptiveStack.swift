//
//  AdaptiveStack.swift
//  DesignSystem
//
//  Created by Sevar Jafarli on 05.10.26.
//

import SwiftUI

/// A horizontal row that stacks vertically at accessibility text sizes, so long text and controls never overflow.
public struct AdaptiveStack<Content: View>: View {
    private let spacing: CGFloat
    private let content: Content

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    public init(spacing: CGFloat = Spacing.md, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: spacing))
            : AnyLayout(HStackLayout(spacing: spacing))

        layout {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
