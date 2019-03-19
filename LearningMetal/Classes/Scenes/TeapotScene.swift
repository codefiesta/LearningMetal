//
//  TeapotScene.swift
//  LearningMetal
//
//  Created by Kevin McKee on 3/19/19.
//  Copyright © 2019 Procore. All rights reserved.
//

import MetalKit

class TeapotScene: DefaultSceneRenderer {
    
    let nodeName = "Teapot"
    var time: Float = 0
    
    override func update(_ view: MTKView, descriptor: MTLRenderPassDescriptor) {
        
        guard let scene = scene else { return }
        
        descriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.5, 0, 0.9, 1.0)
        cameraWorldPosition = float3(0, 0, 5)

        viewMatrix = float4x4(translationBy: -cameraWorldPosition) * float4x4(rotationAbout: float3(1, 0, 0), by: .pi / 6)
        
        let aspectRatio = Float(view.drawableSize.width / view.drawableSize.height)
        projectionMatrix = float4x4(perspectiveProjectionFov: Float.pi / 6, aspectRatio: aspectRatio, nearZ: 0.1, farZ: 100)

        time += 1 / Float(view.preferredFramesPerSecond)
        
        if let node = scene.nodeNamed(nodeName) {
            // Tip the teapot up and down to pour some tea
            let z = Float(0.25 * sin(time * 5))
            let zRotation = float4x4(rotationAbout: float3(0, 0, 1), by: z)
            node.modelMatrix = zRotation
        }
    }
    
    /// Builds the teapot scene which is a simple node
    override func buildScene() -> Scene? {
        let bufferAllocator = MTKMeshBufferAllocator(device: device)
        let textureLoader = MTKTextureLoader(device: device)
        let options: [MTKTextureLoader.Option : Any] = [.generateMipmaps : true, .SRGB : true]
        
        let scene = Scene()
        
        scene.ambientLightColor = float3(0.1, 0.1, 0.1)
        let light0 = Light(worldPosition: float3( 5,  5, 0), color: float3(0.3, 0.3, 0.3))
        let light1 = Light(worldPosition: float3(-5,  5, 0), color: float3(0.3, 0.3, 0.3))
        let light2 = Light(worldPosition: float3( 0, -5, 0), color: float3(0.3, 0.3, 0.3))
        scene.lights = [ light0, light1, light2 ]
        
        let node = Node(name: nodeName)
        let nodeMaterial = Material()
        let nodeBaseColorTexture = try? textureLoader.newTexture(name: "tilesTexture",
                                                                 scaleFactor: 1.0,
                                                                 bundle: nil,
                                                                 options: options)
        nodeMaterial.baseColorTexture = nodeBaseColorTexture
        nodeMaterial.specularPower = 100
        nodeMaterial.specularColor = float3(0.8, 0.8, 0.8)
        node.material = nodeMaterial
        
        let nodeURL = Bundle.main.url(forResource: "teapot", withExtension: "obj")!
        let nodeAsset = MDLAsset(url: nodeURL, vertexDescriptor: vertexDescriptor, bufferAllocator: bufferAllocator)
        node.mesh = try! MTKMesh.newMeshes(asset: nodeAsset, device: device).metalKitMeshes.first!
        scene.rootNode.children.append(node)
        return scene
    }
    
}

