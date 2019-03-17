//
//  SceneRenderer.swift
//  LearningMetal
//
//  Created by Kevin McKee on 3/17/19.
//  Copyright © 2019 Procore. All rights reserved.
//

import Foundation
import MetalKit
import simd

struct VertexUniforms {
    var viewProjectionMatrix: float4x4
    var modelMatrix: float4x4
    var normalMatrix: float3x3
}

struct FragmentUniforms {
    var cameraWorldPosition = float3(0, 0, 0)
    var ambientLightColor = float3(0, 0, 0)
    var specularColor = float3(1, 1, 1)
    var specularPower = Float(1)
    var light0 = Light()
    var light1 = Light()
    var light2 = Light()
}

/// Provides the basic scene rendering protocol
protocol SceneRenderer: MTKViewDelegate {
    // Initalization
    init?(_ view: MTKView)
    // The update function called in draw which subclasses should implement
    func update(_ view: MTKView)
    // Builds the appropriate scene which subclasses should implement
    func buildScene() -> Scene?
}

extension SceneRenderer {
    
    // No-op implementation
    func update(_ view: MTKView) { }
    // No-op implementation
    func buildScene() -> Scene? { return nil }
}

class DefaultSceneRenderer: NSObject, SceneRenderer {

    // The shader function names
    private static let vertexFunction = "vertexMain"
    private static let fragmentFunction = "fragmentMain"

    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let vertexDescriptor: MDLVertexDescriptor
    var renderPipeline: MTLRenderPipelineState
    let samplerState: MTLSamplerState
    let depthStencilState: MTLDepthStencilState

    var cameraWorldPosition = float3(0, 0, 2)
    var viewMatrix = matrix_identity_float4x4
    var projectionMatrix = matrix_identity_float4x4
    var scene: Scene?

    required init?(_ view: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue(),
            let samplerState = DefaultSceneRenderer.buildSamplerState(device: device),
            let depthStencilState = DefaultSceneRenderer.buildDepthStencilState(device: device) else {
            print("😢 Metal not available")
            return nil
        }
        view.device = device
        self.device = device
        self.commandQueue = commandQueue
        self.vertexDescriptor = DefaultSceneRenderer.buildVertexDescriptor()
        self.renderPipeline = DefaultSceneRenderer.buildPipeline(device: device, view: view, vertexDescriptor: vertexDescriptor)
        self.samplerState = samplerState
        self.depthStencilState = depthStencilState
        super.init()
        self.scene = buildScene()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { }
    
    func draw(in view: MTKView) {

        guard let scene = scene, let drawable = view.currentDrawable, let renderPassDescriptor = view.currentRenderPassDescriptor,
            let commandBuffer = commandQueue.makeCommandBuffer() else { return }

        update(view)
        
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.63, 0.81, 1.0, 1.0)
        let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        commandEncoder.setFrontFacing(.counterClockwise)
        commandEncoder.setCullMode(.back)
        commandEncoder.setDepthStencilState(depthStencilState)
        commandEncoder.setRenderPipelineState(renderPipeline)
        commandEncoder.setFragmentSamplerState(samplerState, index: 0)
        drawNodeTree(scene.rootNode, parentTransform: matrix_identity_float4x4, commandEncoder: commandEncoder)
        commandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    /// Recusrively draws the node tree and all of it's descendants
    func drawNodeTree(_ node: Node?, parentTransform: float4x4, commandEncoder: MTLRenderCommandEncoder) {
        
        guard let scene = scene, let node = node else { return }
        let modelMatrix = parentTransform * node.modelMatrix
        
        if let mesh = node.mesh, let baseColorTexture = node.material.baseColorTexture {
            let viewProjectionMatrix = projectionMatrix * viewMatrix
            var vertexUniforms = VertexUniforms(viewProjectionMatrix: viewProjectionMatrix,
                                                modelMatrix: modelMatrix,
                                                normalMatrix: modelMatrix.normalMatrix)
            commandEncoder.setVertexBytes(&vertexUniforms, length: MemoryLayout<VertexUniforms>.size, index: 1)
            
            var fragmentUniforms = FragmentUniforms(cameraWorldPosition: cameraWorldPosition,
                                                    ambientLightColor: scene.ambientLightColor,
                                                    specularColor: node.material.specularColor,
                                                    specularPower: node.material.specularPower,
                                                    light0: scene.lights[0],
                                                    light1: scene.lights[1],
                                                    light2: scene.lights[2])
            commandEncoder.setFragmentBytes(&fragmentUniforms, length: MemoryLayout<FragmentUniforms>.size, index: 0)
            
            commandEncoder.setFragmentTexture(baseColorTexture, index: 0)
            
            let vertexBuffer = mesh.vertexBuffers.first!
            commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: vertexBuffer.offset, index: 0)
            
            for submesh in mesh.submeshes {
                let indexBuffer = submesh.indexBuffer
                commandEncoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                                     indexCount: submesh.indexCount,
                                                     indexType: submesh.indexType,
                                                     indexBuffer: indexBuffer.buffer,
                                                     indexBufferOffset: indexBuffer.offset)
            }
        }
        
        for child in node.children {
            drawNodeTree(child, parentTransform: modelMatrix, commandEncoder: commandEncoder)
        }
    }
}

/// MARK: Factory Methods
extension DefaultSceneRenderer {

    // Builds the vertex descriptor
    static func buildVertexDescriptor() -> MDLVertexDescriptor {
        let vertexDescriptor = MDLVertexDescriptor()
        vertexDescriptor.attributes[0] = MDLVertexAttribute(name: MDLVertexAttributePosition,
                                                            format: .float3,
                                                            offset: 0,
                                                            bufferIndex: 0)
        vertexDescriptor.attributes[1] = MDLVertexAttribute(name: MDLVertexAttributeNormal,
                                                            format: .float3,
                                                            offset: MemoryLayout<Float>.size * 3,
                                                            bufferIndex: 0)
        vertexDescriptor.attributes[2] = MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate,
                                                            format: .float2,
                                                            offset: MemoryLayout<Float>.size * 6,
                                                            bufferIndex: 0)
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: MemoryLayout<Float>.size * 8)
        return vertexDescriptor
    }

    /// Builds the render pipeline state
    static func buildPipeline(device: MTLDevice, view: MTKView, vertexDescriptor: MDLVertexDescriptor) -> MTLRenderPipelineState {
        guard let library = device.makeDefaultLibrary() else {
            fatalError("Could not load default library from main bundle")
        }
        
        let vertexFunction = library.makeFunction(name: DefaultSceneRenderer.vertexFunction)
        let fragmentFunction = library.makeFunction(name: DefaultSceneRenderer.fragmentFunction)
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = view.depthStencilPixelFormat
        
        let mtlVertexDescriptor = MTKMetalVertexDescriptorFromModelIO(vertexDescriptor)
        pipelineDescriptor.vertexDescriptor = mtlVertexDescriptor
        
        do {
            return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError("Could not create render pipeline state object: \(error)")
        }
    }

    /// Builds the sampler state
    static func buildSamplerState(device: MTLDevice) -> MTLSamplerState? {
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.normalizedCoordinates = true
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.mipFilter = .linear
        return device.makeSamplerState(descriptor: samplerDescriptor)
    }

    /// Builds the depth stencil state
    static func buildDepthStencilState(device: MTLDevice) -> MTLDepthStencilState? {
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        return device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }
}
