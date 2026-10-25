//
//  CameraAccess.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 25.10.26.
//

import AVFoundation
import UIKit

@MainActor
enum CameraAccess {
    static var isAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    static func request() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            true
        case .notDetermined:
            await AVCaptureDevice.requestAccess(for: .video)
        default:
            false
        }
    }
}
