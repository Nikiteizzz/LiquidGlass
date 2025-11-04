import SwiftUI

struct LiquidGlassDemoView: View {
    @State
    private var isGlassViewDemoShown = false
    
    var body: some View {
        ZStack {
            background
            
            glassSheets
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
    
    @ViewBuilder
    private var glassSheets: some View {
        VStack {
            Toggle("Glass View", isOn: $isGlassViewDemoShown)
                .padding(.horizontal, 20)
                .frame(height: 100)
                .liquidGlassBackground(.init(corner: 30, tint: Color.red.opacity(0.1)))
                .padding(.horizontal, 30)
            
            LazyVGrid(columns: [.init(), .init()]) {
                if isGlassViewDemoShown {
                    glassViewDemo(configuration: .basic, type: .clear, index: 1)
                    glassViewDemo(configuration: .basic, type: .regular, index: 2)
                    glassViewDemo(configuration: .init(corner: 20), type: .clear, index: 3)
                    glassViewDemo(configuration: .init(corner: 20), type: .regular, index: 4)
                    glassViewDemo(configuration: .init(corner: 20, tint: .black.opacity(0.3)), type: .clear, index: 5)
                    glassViewDemo(configuration: .init(corner: 20, tint: .black.opacity(0.3)), type: .regular, index: 6)
                    glassViewDemo(configuration: .init(corner: 20, tint: .white.opacity(0.3)), type: .clear, index: 7)
                    glassViewDemo(configuration: .init(corner: 20, tint: .white.opacity(0.3)), type: .regular, index: 8)
                } else {
                    glassModifierDemo(configuration: .basic, type: .clear, index: 1)
                    glassModifierDemo(configuration: .basic, type: .regular, index: 2)
                    glassModifierDemo(configuration: .init(corner: 20), type: .clear, index: 3)
                    glassModifierDemo(configuration: .init(corner: 20), type: .regular, index: 4)
                    glassModifierDemo(configuration: .init(corner: 20, tint: .black.opacity(0.3)), type: .clear, index: 5)
                    glassModifierDemo(configuration: .init(corner: 20, tint: .black.opacity(0.3)), type: .regular, index: 6)
                    glassModifierDemo(configuration: .init(corner: 20, tint: .white.opacity(0.3)), type: .clear, index: 7)
                    glassModifierDemo(configuration: .init(corner: 20, tint: .white.opacity(0.3)), type: .regular, index: 8)
                }
            }
        }
    }
}



#Preview {
    LiquidGlassDemoView()
}
