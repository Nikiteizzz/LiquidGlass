import SwiftUI

public struct LiquidGlassView: View {
    @State
    var configuration: Configuration = .basic
    @State
    var glassType: GlassType = .regular
    
    public var body: some View {
        LiquidGlassMetalViewRepresentable(corner: configuration.corner, glassType: glassType)
            .overlay {
                configuration.tint
                    .clipShape(.rect(cornerRadius: configuration.corner))
            }
            .liquidGlassBorder(corner: configuration.corner)
        
    }
    
    func liquidGlassOverlay<Overlay: View>(_ content: @escaping () -> Overlay) -> some View {
        self.overlay(content: {
            NonRenderableHostingViewRepresentable(content: content)
        })
    }
}

public extension LiquidGlassView {
    struct Configuration: Sendable {
        public static let basic = Configuration()
        
        var corner: CGFloat = .zero
        var tint: Color = .clear
    }
    
    struct GlassType: Sendable {
        public static let clear = GlassType(height: 10, amount: 30, depthEffect: 0)
        public static let regular = GlassType(height: 20, amount: 60, depthEffect: 1)
        public static func custom(height: CGFloat = 20, amount: CGFloat = 30, depthEffect: CGFloat = 1) -> GlassType {
            .init(height: height, amount: amount, depthEffect: depthEffect)
        }
        
        var height: CGFloat
        var amount: CGFloat
        var depthEffect: CGFloat
    }
}
