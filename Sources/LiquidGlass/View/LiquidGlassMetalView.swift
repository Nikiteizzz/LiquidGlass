import MetalKit
import SwiftUI

struct RefractionParams {
    var viewSize: SIMD2<Float>
    var shapeSize: SIMD2<Float>
    var cornerRadii: SIMD4<Float>
    var refractionHeight: Float
    var refractionAmount: Float
    var depthEffect: Float
    var padding: Float = 0
}

struct DispersionParams {
    var viewSize: SIMD2<Float>
    var shapeSize: SIMD2<Float>
    var cornerRadii: SIMD4<Float>
    var dispersionHeight: Float
    var dispersionAmount: Float
    var padding: SIMD2<Float> = .zero
}

final class LiquidGlassMetalView: MTKView, MTKViewDelegate {
    private var commandQueue: MTLCommandQueue?
    private var refractionPipeline: MTLRenderPipelineState?
    private var dispersionPipeline: MTLRenderPipelineState?
    private var vertexBuffer: MTLBuffer?
    private var texture: MTLTexture?
    private var intermediateTexture: MTLTexture?
    
    var corner: CGFloat = .zero {
        didSet {
            layer.cornerRadius = corner
            clipsToBounds = true
        }
    }
    
    var effectHeight: CGFloat = 20
    var effectAmount: CGFloat = 10
    var depthEffect: CGFloat = 0

    override init(frame frameRect: CGRect, device: MTLDevice?) {
        let metalDevice = device ?? MTLCreateSystemDefaultDevice()
        super.init(frame: frameRect, device: metalDevice)
        setupMetal()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        self.device = MTLCreateSystemDefaultDevice()
        setupMetal()
    }

    private func setupMetal() {
        guard let device = self.device else {
            return
        }

        colorPixelFormat = .bgra8Unorm
        framebufferOnly = false
        commandQueue = device.makeCommandQueue()

        guard let library = try? device.makeDefaultLibrary(bundle: Bundle.module) else {
            return
        }

        let quadVertices: [SIMD4<Float>] = [
            SIMD4(-1, -1, 0, 1),
            SIMD4( 1, -1, 1, 1),
            SIMD4(-1,  1, 0, 0),
            SIMD4( 1,  1, 1, 0),
        ]
        vertexBuffer = device.makeBuffer(
            bytes: quadVertices,
            length: MemoryLayout<SIMD4<Float>>.stride * quadVertices.count
        )

        func makePipeline(fragmentName: String) -> MTLRenderPipelineState? {
            let descriptor = MTLRenderPipelineDescriptor()
            descriptor.vertexFunction = library.makeFunction(name: "vertex_main")
            descriptor.fragmentFunction = library.makeFunction(name: fragmentName)
            descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            return try? device.makeRenderPipelineState(descriptor: descriptor)
        }

        refractionPipeline = makePipeline(fragmentName: "roundedRectRefractionFragment")
        dispersionPipeline = makePipeline(fragmentName: "roundedRectDispersionFragment")

        delegate = self
    }

    func setImage(_ image: UIImage?) {
        guard let image = image,
              let cgImage = image.cgImage,
              let device = device else {
            texture = nil
            return
        }

        let textureLoader = MTKTextureLoader(device: device)
        do {
            texture = try textureLoader.newTexture(cgImage: cgImage, options: [.SRGB: false])
        } catch {
            texture = nil
        }
    }

    private func ensureIntermediateTexture(size: CGSize) {
        guard let device = device else { return }
        if let tex = intermediateTexture,
           tex.width == Int(size.width),
           tex.height == Int(size.height) {
            return
        }
        let desc = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: Int(size.width),
            height: Int(size.height),
            mipmapped: false
        )
        desc.usage = [.renderTarget, .shaderRead, .shaderWrite]
        intermediateTexture = device.makeTexture(descriptor: desc)
    }

    func draw(in view: MTKView) {
        guard let drawable = currentDrawable,
              let commandQueue = commandQueue,
              let refractionPipeline = refractionPipeline,
              let dispersionPipeline = dispersionPipeline,
              let vertexBuffer = vertexBuffer else {
            return
        }

        ensureIntermediateTexture(size: drawableSize)

        guard let intermediate = intermediateTexture,
              let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }

        let samplerDesc = MTLSamplerDescriptor()
        samplerDesc.minFilter = .linear
        samplerDesc.magFilter = .linear
        samplerDesc.sAddressMode = .clampToEdge
        samplerDesc.tAddressMode = .clampToEdge
        let sampler = device?.makeSamplerState(descriptor: samplerDesc)

        let refractionPass = MTLRenderPassDescriptor()
        refractionPass.colorAttachments[0].texture = intermediate
        refractionPass.colorAttachments[0].loadAction = .clear
        refractionPass.colorAttachments[0].storeAction = .store
        refractionPass.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0)

        if let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: refractionPass) {
            encoder.setRenderPipelineState(refractionPipeline)
            encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            if let texture = texture {
                encoder.setFragmentTexture(texture, index: 0)
            }
            if let sampler = sampler {
                encoder.setFragmentSamplerState(sampler, index: 0)
            }

            var refParams = RefractionParams(
                viewSize: SIMD2(Float(bounds.size.width), Float(bounds.size.height)),
                shapeSize: SIMD2(Float(bounds.size.width), Float(bounds.size.height)),
                cornerRadii: SIMD4(Float(corner), Float(corner), Float(corner), Float(corner)),
                refractionHeight: Float(effectHeight),
                refractionAmount: -Float(effectAmount),
                depthEffect: Float(depthEffect)
            )
            encoder.setFragmentBytes(&refParams, length: MemoryLayout<RefractionParams>.stride, index: 1)
            encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            encoder.endEncoding()
        }

        guard let finalPass = currentRenderPassDescriptor else { return }

        if let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: finalPass) {
            encoder.setRenderPipelineState(dispersionPipeline)
            encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

            encoder.setFragmentTexture(intermediate, index: 0)
            if let sampler = sampler {
                encoder.setFragmentSamplerState(sampler, index: 0)
            }

            var dispParams = DispersionParams(
                viewSize: SIMD2(Float(bounds.size.width), Float(bounds.size.height)),
                shapeSize: SIMD2(Float(bounds.size.width), Float(bounds.size.height)),
                cornerRadii: SIMD4(Float(corner), Float(corner), Float(corner), Float(corner)),
                dispersionHeight: Float(effectHeight),
                dispersionAmount: Float(effectAmount)
            )
            encoder.setFragmentBytes(&dispParams, length: MemoryLayout<DispersionParams>.stride, index: 1)
            encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            encoder.endEncoding()
        }

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}
