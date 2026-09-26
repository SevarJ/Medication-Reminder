//
//  CommonText.swift
//  AppLocalization
//
//  Created by Sevar Jafarli on 26.09.26.
//

import Foundation

public enum CommonText {
    public static var ok: String {
        String(localized: "common.ok", defaultValue: "OK", bundle: .module.localized())
    }

    public static var cancel: String {
        String(localized: "common.cancel", defaultValue: "Cancel", bundle: .module.localized())
    }

    public static var save: String {
        String(localized: "common.save", defaultValue: "Save", bundle: .module.localized())
    }

    public static var tryAgain: String {
        String(localized: "common.tryAgain", defaultValue: "Try Again", bundle: .module.localized())
    }

    public static var delete: String {
        String(localized: "common.delete", defaultValue: "Delete", bundle: .module.localized())
    }

    public static var errorTitle: String {
        String(localized: "common.error.title", defaultValue: "Something Went Wrong", bundle: .module.localized())
    }
}
