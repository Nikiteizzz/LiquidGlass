import SwiftUI

public struct LiquidGlassMetalViewRepresentable: UIViewRepresentable {
    @StateObject
    private var globalScreenCapturer = GlobalWindowCapturer.shared
    @State
    public var corner: CGFloat = .zero
    @State
    public var glassType: LiquidGlassView.GlassType = .regular
    
    public func makeUIView(context: Context) -> LiquidGlassMetalView {
        let view = LiquidGlassMetalView(frame: .zero)
        view.corner = corner
        view.depthEffect = glassType.depthEffect
        view.effectHeight = glassType.height
        view.effectAmount = glassType.amount
        
        return view
    }
    
    public func updateUIView(_ uiView: LiquidGlassMetalView, context: Context) {
        uiView.depthEffect = glassType.depthEffect
        uiView.effectHeight = glassType.height
        uiView.effectAmount = glassType.amount
        uiView.corner = corner
        
        uiView.setImage(prepareImage(globalScreenCapturer.lastCapturedImage, for: uiView))
    }
    
    private func prepareImage(_ source: UIImage, for view: UIView) -> UIImage {
        guard
            let window = view.window
        else { return .init() }
        
        let frameInWindow = view.convert(view.bounds, to: window)
        return source.cropped(to: frameInWindow)
    }
}
