//
//  ProgressRing.swift
//  DesignSystem
//
//  Created by Sevar Jafarli on 24.09.26.
//

import SwiftUI

public struct ProgressRing: View {
    private let progress: Double
    private let lineWidth: CGFloat
    private let tint: Color
    
    public init(
        progress: Double,
        lineWidth: CGFloat = 8,
        tint: Color = Color.theme.accent
    ) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.tint = tint
    }
    
    public var body: some View {
        ZStack {
            Circle()
                .stroke(Color.theme.accentTint, lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .padding(lineWidth / 2)
        .animation(.spring(duration: 0.6), value: progress)
    }
}
