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
        f.scale = 0.8
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

        let allLiquidGlassView = window.rootViewController?.view.allSubviews(ofType: LiquidGlassMetalView.self) ?? []
        let allLiquidGlassOverlays = window.rootViewController?.view.allSubviews(where: { view in
            view.layer is NonRenderableLayer
        }) ?? []
    
        let liquidGlassRects = allLiquidGlassView.map { $0.convert($0.bounds, to: window) }
        
        let renderer = UIGraphicsImageRenderer(bounds: window.bounds, format: captureFormat)
        renderer.image { context in
            context.cgContext.clip(to: liquidGlassRects)
            window.layer.presentation()?.render(in: context.cgContext)
            
            allLiquidGlassView.enumerated().forEach { index, view in
                view.setInputImage(context.currentImage)
                let bounds = view.convert(view.bounds, to: window)
                view.drawHierarchy(in: bounds, afterScreenUpdates: false)
                let overlay = allLiquidGlassOverlays[index]
                let overlayBounds = overlay.convert(overlay.bounds, to: window)
                overlay.drawHierarchy(in: overlayBounds, afterScreenUpdates: false)
            }
        }
    }
    
    private func currentKeyWindow() -> UIWindow? {
        (UIApplication.shared.connectedScenes.first { $0.activationState == .foregroundActive } as? UIWindowScene)?.keyWindow
    }
}


