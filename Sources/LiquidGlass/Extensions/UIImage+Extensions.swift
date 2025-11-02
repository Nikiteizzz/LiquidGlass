import UIKit

internal extension UIImage {
    func cropped(to rect: CGRect) -> UIImage {
        guard let cgImage = self.cgImage else { return .init() }

        let scaledRect = CGRect(
            x: rect.origin.x * scale,
            y: rect.origin.y * scale,
            width: rect.size.width * scale,
            height: rect.size.height * scale
        ).integral

        let clippedRect = CGRect(
            x: max(0, min(scaledRect.origin.x, CGFloat(cgImage.width))),
            y: max(0, min(scaledRect.origin.y, CGFloat(cgImage.height))),
            width: min(scaledRect.size.width, CGFloat(cgImage.width) - scaledRect.origin.x),
            height: min(scaledRect.size.height, CGFloat(cgImage.height) - scaledRect.origin.y)
        )

        guard let croppedCG = cgImage.cropping(to: clippedRect) else { return .init() }

        return UIImage(cgImage: croppedCG, scale: scale, orientation: imageOrientation)
    }
}
