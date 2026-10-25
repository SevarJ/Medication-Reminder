//
//  MedicationPhoto.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 06.10.26.
//

import Foundation
import UIKit

/// Shrinks a picked photo so it can live inside the medication itself.
enum MedicationPhoto {
    static let maxDimension: CGFloat = 400
    static let maxBytes = 60_000
    
    static func compressed(_ data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        
        let longestSide = max(image.size.width, image.size.height)
        let scale = longestSide > maxDimension ? maxDimension / longestSide : 1
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        let resized = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        
        for quality in [0.7, 0.5, 0.3] {
            if let jpeg = resized.jpegData(compressionQuality: quality), jpeg.count <= maxBytes {
                return jpeg
            }
        }
        
        return nil
    }
}
