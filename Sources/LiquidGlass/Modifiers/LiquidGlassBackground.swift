import SwiftUI

public struct LiquidGlassBackground: ViewModifier {
    @State
    public var configuration: LiquidGlassView.Configuration
    @State
    public var type: LiquidGlassView.GlassType
    
    public init(configuration: LiquidGlassView.Configuration = .basic, type: LiquidGlassView.GlassType = .regular) {
        self.configuration = configuration
        self.type = type
    }
    
    public func body(content: Content) -> some View {
        content
            .opacity(0)
            .background {
                LiquidGlassView(configuration: configuration, glassType: type)
                    .liquidGlassOverlay {
                        content
                    }
            }
    }
}

public extension View {
    func liquidGlassBackground(
        _ configuration: LiquidGlassView.Configuration = .basic,
        glassType: LiquidGlassView.GlassType = .regular
    ) -> some View {
        modifier(
            LiquidGlassBackground(
                configuration: configuration,
                type: glassType
            )
        )
    }
}
