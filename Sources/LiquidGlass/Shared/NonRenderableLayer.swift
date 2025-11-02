import SwiftUI

final class NonRenderableLayer: CALayer {
    override func render(in ctx: CGContext) { }
}
