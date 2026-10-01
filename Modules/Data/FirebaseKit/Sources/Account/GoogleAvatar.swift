//
//  GoogleAvatar.swift
//  FirebaseKit
//
//  Created by Sevar Jafarli on 01.10.26.
//

import Foundation

/// Google hands out account photos at 96 px unless the URL asks for more, which is blurry on a profile screen.
enum GoogleAvatar {
    static let pixelSize = 400

    private static let defaultSuffix = "=s96-c"

    static func enlarged(_ url: URL) -> URL {
        let address = url.absoluteString

        guard url.host()?.hasSuffix("googleusercontent.com") == true, address.hasSuffix(defaultSuffix) else {
            return url
        }

        return URL(string: address.dropLast(defaultSuffix.count) + "=s\(pixelSize)-c") ?? url
    }
}
