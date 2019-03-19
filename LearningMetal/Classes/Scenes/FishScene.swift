//
//  FishScene.swift
//  LearningMetal
//
//  Created by Kevin McKee on 3/17/19.
//  Copyright © 2019 Procore. All rights reserved.
//

import MetalKit

class FishScene: DefaultSceneRenderer {
    
    private let nodeName = "Fishy"
    private let fishCount = 8
    private var time: Float = 0
    
    override func update(_ view: MTKView, descriptor: MTLRenderPassDescriptor) {
        
        guard let scene = scene else { return }
        descriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 0.5, 0.5, 1.0)
        
        time += 1 / Float(view.preferredFramesPerSecond)
        
        cameraWorldPosition = float3(0, 0, 5)
        
        viewMatrix = float4x4(translationBy: -cameraWorldPosition) * float4x4(rotationAbout: float3(1, 0, 0), by: .pi / 6)
        
        let aspectRatio = Float(view.drawableSize.width / view.drawableSize.height)
        projectionMatrix = float4x4(perspectiveProjectionFov: Float.pi / 6, aspectRatio: aspectRatio, nearZ: 0.1, farZ: 100)
        
        let angle = -time
        scene.rootNode.modelMatrix = float4x4(rotationAbout: float3(0, 1, 0), by: angle)
        
        let fishBaseTransform = float4x4(rotationAbout: float3(0, 0, 1), by: -.pi / 2) *
            float4x4(scaleBy: 0.25) *
            float4x4(rotationAbout: float3(0, 1, 0), by: -.pi / 2)
        
        for i in 1...fishCount {
            guard let fish = scene.nodeNamed("\(nodeName) \(i)") else { continue }

            let pivotPosition = float3(0.4, 0, 0)
            let rotationOffset = float3(0.4, 0, 0)
            let rotationSpeed = Float(0.3)
            let rotationAngle = 2 * Float.pi * Float(rotationSpeed * time) + (2 * Float.pi / Float(fishCount) * Float(i - 1))
            let horizontalAngle = 2 * .pi / Float(fishCount) * Float(i - 1)
            fish.modelMatrix = float4x4(rotationAbout: float3(0, 1, 0), by: horizontalAngle) *
                float4x4(translationBy: rotationOffset) *
                float4x4(rotationAbout: float3(0, 0, 1), by: rotationAngle) *
                float4x4(translationBy: pivotPosition) * fishBaseTransform
        }
    }
    
    /// Builds the fish scene which is an array of fish nodes
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
        
        let fishMaterial = Material()
        let fishTexture = try? textureLoader.newTexture(name: "fishTexture",
                                                                 scaleFactor: 1.0,
                                                                 bundle: nil,
                                                                 options: options)
        fishMaterial.baseColorTexture = fishTexture
        fishMaterial.specularPower = 40
        fishMaterial.specularColor = float3(0.8, 0.8, 0.8)
        
        let fishURL = Bundle.main.url(forResource: "fish", withExtension: "obj")!
        let fishAsset = MDLAsset(url: fishURL, vertexDescriptor: vertexDescriptor, bufferAllocator: bufferAllocator)
        let fishMesh = try! MTKMesh.newMeshes(asset: fishAsset, device: device).metalKitMeshes.first!
        
        for i in 1...fishCount {
            let fish = Node(name: "\(nodeName) \(i)")
            fish.material = fishMaterial
            fish.mesh = fishMesh
            scene.rootNode.children.append(fish)
        }
        return scene
    }
    
}
