import SwiftUI

struct LiquidGlassBackground: ViewModifier {
    @State
    var configuration: LiquidGlassView.Configuration = .basic
    @State
    var type: LiquidGlassView.GlassType = .regular
    
    func body(content: Content) -> some View {
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

extension View {
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
