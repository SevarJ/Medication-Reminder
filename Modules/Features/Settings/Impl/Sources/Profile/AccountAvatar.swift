//
//  AccountAvatar.swift
//  SettingsImpl
//
//  Created by Sevar Jafarli on 01.10.26.
//

import DesignSystem
import SwiftUI

struct AccountAvatar: View {
    let photoURL: URL?
    let size: CGFloat
    
    var body: some View {
        AsyncImage(url: photoURL) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFill()
            }
            else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .accessibilityHidden(true)
    }
    
    private var placeholder: some View {
        Image(systemName: "person.fill")
            .font(.system(size: size * 0.45))
            .foregroundStyle(Color.theme.accent)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.theme.accentTint)
    }
}
