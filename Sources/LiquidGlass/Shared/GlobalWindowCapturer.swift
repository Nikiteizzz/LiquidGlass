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
    
    @objc @MainActor private func capture() {
        guard
            let window = currentKeyWindow()
        else { return }
        
        let rendererFormat = UIGraphicsImageRendererFormat()
        rendererFormat.scale = 0.4
        rendererFormat.preferredRange = .standard
        
        let allLiquidGlassView = window.rootViewController?.view.allSubviews(ofType: LiquidGlassMetalView.self) ?? []
        let liquidGlassRects = allLiquidGlassView.map { $0.convert($0.bounds, to: window) }
        
        let renderer = UIGraphicsImageRenderer(bounds: window.bounds, format: rendererFormat)
        renderer.image { context in
            context.cgContext.clip(to: liquidGlassRects)
            window.layer.render(in: context.cgContext)
            
            window.rootViewController?.view.subviews.forEach {
                if $0.subviews.contains(where: { ($0 is LiquidGlassMetalView) }) {
                    let frameInWindow = $0.convert($0.bounds, to: window)
                    let currentImage = context.currentImage
                    $0.subviews.compactMap { $0 as? LiquidGlassMetalView }.forEach { $0.setInputImage(currentImage) }
                    $0.drawHierarchy(in: frameInWindow, afterScreenUpdates: false)
                } else {
                    let frameInWindow = $0.convert($0.bounds, to: window)
                    $0.drawHierarchy(in: frameInWindow, afterScreenUpdates: false)
                }
            }
        }
    }
    
    @MainActor
    private func drawViewHierarchy(_ view: UIView, window: UIWindow) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        
        return renderer.image { context in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        }
    }

    
    @MainActor
    private func currentKeyWindow() -> UIWindow? {
        (UIApplication.shared.connectedScenes.first { $0.activationState == .foregroundActive } as? UIWindowScene)?.keyWindow
    }
}


