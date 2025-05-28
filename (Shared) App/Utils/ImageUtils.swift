//
//  ImageUtils.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 5/27/25.
//

import CoreGraphics
import CoreImage
import Foundation
import ImageIO

func loadCorrectedCGImage(from data: Data) -> CGImage? {
    guard let source = CGImageSourceCreateWithData(data as CFData, nil),
          let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil)
    else {
        return nil
    }

    let orientationRaw = (CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any])?[kCGImagePropertyOrientation] as? UInt32 ?? 1

    let ciImage = CIImage(cgImage: cgImage).oriented(forExifOrientation: Int32(orientationRaw))
    let context = CIContext()
    return context.createCGImage(ciImage, from: ciImage.extent)
}
