import SwiftUI

public struct LiquidGlassMetalViewRepresentable: UIViewRepresentable {
    @StateObject
    private var globalScreenCapturer = GlobalWindowCapturer.shared
    @State
    public var corner: CGFloat
    @State
    public var glassType: LiquidGlassView.GlassType
    
    public init(corner: CGFloat = .zero, glassType: LiquidGlassView.GlassType = .regular) {
        self.corner = corner
        self.glassType = glassType
    }
    
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
    }
    
    private func prepareImage(_ source: UIImage, for view: UIView) -> UIImage {
        guard
            let window = view.window
        else { return .init() }
        
        let frameInWindow = view.convert(view.bounds, to: window)
        return source.cropped(to: frameInWindow)
    }
}
