//
//  MedicationAvatar.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 06.10.26.
//

import DesignSystem
import SwiftUI
import UIKit

/// The picture of a medication's pack, or the pill glyph when there is none.
struct MedicationAvatar: View {
    let photo: Data?
    let isActive: Bool
    var size: CGFloat = 44
    
    @ScaledMetric private var scaledSize: CGFloat
    
    init(photo: Data?, isActive: Bool = true, size: CGFloat = 44) {
        self.photo = photo
        self.isActive = isActive
        self.size = size
        _scaledSize = ScaledMetric(wrappedValue: size)
    }
    
    var body: some View {
        if let photo, let image = UIImage(data: photo) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: scaledSize, height: scaledSize)
                .clipShape(RoundedRectangle(cornerRadius: scaledSize * 0.3, style: .continuous))
                .opacity(isActive ? 1 : 0.6)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                .accessibilityHidden(true)
        }
        else {
            IconTile(
                systemName: "pills.fill",
                foreground: isActive ? Color.theme.accentText : Color.theme.textSecondary,
                background: isActive ? Color.theme.accentTint : Color.theme.fill,
                size: size
            )
        }
    }
}
