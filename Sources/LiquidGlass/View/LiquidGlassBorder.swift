import SwiftUI

public struct LiquidGlassBorder: ViewModifier {
    @State
    public var cornerRadius: CGFloat
    
    public init(cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius
    }
    
    public func body(content: Content) -> some View {
        content
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            stops: [
                                .init(color: .black.opacity(0.2), location: 0),
                                .init(color: .white, location: 0.15),
                                .init(color: .white, location: 0.85),
                                .init(color: .black.opacity(0.2), location: 1)
                            ],
                            startPoint: .bottomLeading,
                            endPoint: .topTrailing
                        ),
                        lineWidth: 1
                    )
                    .opacity(0.3)
            }
    }
}

public extension View {
    func liquidGlassBorder(corner: CGFloat) -> some View {
        modifier(LiquidGlassBorder(cornerRadius: corner))
    }
}
