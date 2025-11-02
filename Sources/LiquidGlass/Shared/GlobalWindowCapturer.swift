import SwiftUI

final class GlobalWindowCapturer: ObservableObject {
    nonisolated(unsafe) static let shared = GlobalWindowCapturer()
    
    private var displayLink: CADisplayLink?
    
    private var captureFormat: UIGraphicsImageRendererFormat {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 0.3
        format.preferredRange = .standard
        
        return format
    }
    
    @Published
    var lastCapturedImage: UIImage = .init()
    
    init() {
        setupCapture()
    }
    
    deinit {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    private func setupCapture() {
        displayLink = .init(target: self, selector: #selector(capture))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc @MainActor private func capture() {
        guard
            let window = currentKeyWindow()
        else { return }
        
        let capturer = UIGraphicsImageRenderer(bounds: window.bounds, format: captureFormat)
        
        let capturedImage = capturer.image { context in
            window.layer.render(in: context.cgContext)
        }
        
        lastCapturedImage = capturedImage
    }
    
    @MainActor
    private func currentKeyWindow() -> UIWindow? {
        (UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene)?.keyWindow
    }
}
