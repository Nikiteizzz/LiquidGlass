import SwiftUI
import UIKit
import MetalKit

protocol WindowRenderObserver: AnyObject {
    func setInputImage(_ image: UIImage)
}

final class GlobalWindowCapturer: ObservableObject {
    nonisolated(unsafe) static let shared = GlobalWindowCapturer()
    
    private var displayLink: CADisplayLink?
    private var observers: [WindowRenderObserver] = []
    
    private var captureFormat: UIGraphicsImageRendererFormat {
        let f = UIGraphicsImageRendererFormat()
        f.scale = 0.5
        f.preferredRange = .standard
        return f
    }
    
    @Published var lastCapturedImage: UIImage = .init()
    
    private init() { setupCapture() }
    deinit { displayLink?.invalidate() }
    
    func addObserver(_ observer: WindowRenderObserver) {
        guard !observers.contains(where: { $0 === observer }) else { return }
        observers.append(observer)
    }
    func removeObserver(_ observer: WindowRenderObserver) {
        observers.removeAll { $0 === observer }
    }
    
    private func setupCapture() {
        displayLink = CADisplayLink(target: self, selector: #selector(capture))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @MainActor
    @objc private func capture() {
        autoreleasepool {
            DispatchQueue.main.async { [self] in
                guard
                    let window = currentKeyWindow(),
                    let rootController = window.rootViewController
                else { return }
                
                let rendererFormat = UIGraphicsImageRendererFormat()
                rendererFormat.scale = 0.9
                rendererFormat.preferredRange = .standard
                
                let allLiquidGlassView = rootController.view.allSubviews(ofType: LiquidGlassMetalView.self)
                let liquidGlassRects = allLiquidGlassView.map { $0.convert($0.bounds, to: window) }
                
                let renderer = UIGraphicsImageRenderer(bounds: window.bounds, format: rendererFormat)
                let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
                let ciContext = CIContext()
                renderer.image { context in
                    context.cgContext.clip(to: liquidGlassRects)
                    window.layer.render(in: context.cgContext)
                    
                    allLiquidGlassView
                        .forEach {
                            $0.setInputImage(context.currentImage)
                        }
                }
            }
        }
    }
    
    private func currentKeyWindow() -> UIWindow? {
        (UIApplication.shared.connectedScenes.first { $0.activationState == .foregroundActive } as? UIWindowScene)?.keyWindow
    }
}


