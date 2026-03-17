import SwiftUI

struct LiquidGlassDemoView: View {
    @State
    private var isGlassViewDemoShown = false
    @State
    private var glassPosition: CGPoint = .init(x: 100, y: 100)
    
    var body: some View {
        ZStack {
            background
            
            glassModifierDemo(configuration: .init(corner: 20, tint: .clear), type: .regular, index: 1)
                .frame(width: 200, height: 200)
            
            glassModifierDemo(configuration: .init(corner: 20, tint: .clear), type: .regular, index: 2)
                .frame(width: 200, height: 200)
                .position(glassPosition)
                .gesture(DragGesture().onChanged({ gesture in
                    glassPosition = gesture.location
                }))
        }
    }
    
    @ViewBuilder
    private var background: some View {
        ScrollView(.vertical) {
            VStack {
                Text("SOME TEST TITLE")
                    .font(.system(size: 32, weight: .bold))
                
                LinearGradient(colors: [.red, .green], startPoint: .top, endPoint: .bottom)
                    .frame(height: 300)
                
                Text("Some More Text")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .green, .red, .purple, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Color.red
                    .frame(height: 300)
                Text("SOME TEST TITLE")
                    .font(.system(size: 32, weight: .bold))
                
                LinearGradient(colors: [.red, .green], startPoint: .top, endPoint: .bottom)
                    .frame(height: 300)
                
                Text("Some More Text")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .green, .red, .purple, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Color.red
                    .frame(height: 300)
                Text("SOME TEST TITLE")
                    .font(.system(size: 32, weight: .bold))
                
                LinearGradient(colors: [.red, .green], startPoint: .top, endPoint: .bottom)
                    .frame(height: 300)
                
                Text("Some More Text")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .green, .red, .purple, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Color.red
                    .frame(height: 300)
                Text("SOME TEST TITLE")
                    .font(.system(size: 32, weight: .bold))
                
                LinearGradient(colors: [.red, .green], startPoint: .top, endPoint: .bottom)
                    .frame(height: 300)
                
                Text("Some More Text")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .green, .red, .purple, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Color.red
                    .frame(height: 300)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 200)
        }
    }
    
    @ViewBuilder
    private func glassViewDemo(configuration: LiquidGlassView.Configuration, type: LiquidGlassView.GlassType, index: Int) -> some View {
        LiquidGlassView(configuration: configuration, glassType: type)
            .liquidGlassOverlay {
                Text("Glass View \(index)")
            }
            .frame(height: 100)
    }
    
    @ViewBuilder
    private func glassModifierDemo(configuration: LiquidGlassView.Configuration, type: LiquidGlassView.GlassType, index: Int) -> some View {
        Text("Glass View \(index)")
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .liquidGlassBackground(configuration, glassType: type)
    }
}



#Preview {
    LiquidGlassDemoView()
}
