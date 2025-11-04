import SwiftUI

public struct LiquidGlassView: View {
    @State
    public var configuration: Configuration
    @State
    public var glassType: GlassType
    
    public init(configuration: Configuration = .basic, glassType: GlassType = .regular) {
        self.configuration = configuration
        self.glassType = glassType
    }
    
    public var body: some View {
        LiquidGlassMetalViewRepresentable(corner: configuration.corner, glassType: glassType)
            .liquidGlassOverlay {
                configuration.tint
                    .clipShape(.rect(cornerRadius: configuration.corner))
            }
            .liquidGlassBorder(corner: configuration.corner)
        
    }
}

public extension LiquidGlassView {
    struct Configuration: Sendable {
        public static let basic = Configuration()
        
        public init(corner: CGFloat = .zero, tint: Color = .clear) {
            self.corner = corner
            self.tint = tint
        }
        
        public var corner: CGFloat = .zero
        public var tint: Color = .clear
    }
    
    struct GlassType: Sendable {
        public static let clear = GlassType(height: 10, amount: 30, depthEffect: 0)
        public static let regular = GlassType(height: 20, amount: 60, depthEffect: 1)
        public static func custom(height: CGFloat = 20, amount: CGFloat = 30, depthEffect: CGFloat = 1) -> GlassType {
            .init(height: height, amount: amount, depthEffect: depthEffect)
        }
        
        public init(height: CGFloat, amount: CGFloat, depthEffect: CGFloat) {
            self.height = height
            self.amount = amount
            self.depthEffect = depthEffect
        }
        
        public var height: CGFloat
        public var amount: CGFloat
        public var depthEffect: CGFloat
    }
}
