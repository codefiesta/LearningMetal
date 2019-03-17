//
//  DuckyScene.swift
//  LearningMetal
//
//  Created by Kevin McKee on 3/17/19.
//  Copyright © 2019 Procore. All rights reserved.
//

import MetalKit

class DuckyScene: DefaultSceneRenderer {
    
    private let nodeName = "Ducky"
    private var time: Float = 0
    
    override func update(_ view: MTKView) {
        
        guard let scene = scene else { return }
        
        time += 1 / Float(view.preferredFramesPerSecond)
        
        cameraWorldPosition = float3(0, 0, 5)

        viewMatrix = float4x4(translationBy: -cameraWorldPosition) * float4x4(rotationAbout: float3(1, 0, 0), by: .pi / 6)
        
        let aspectRatio = Float(view.drawableSize.width / view.drawableSize.height)
        projectionMatrix = float4x4(perspectiveProjectionFov: Float.pi / 6, aspectRatio: aspectRatio, nearZ: 0.1, farZ: 100)
        
        // Rotate the camera angle around the duck
        let angle = -time
        scene.rootNode.modelMatrix = float4x4(rotationAbout: float3(0, 1, 0), by: angle)
        
        if let ducky = scene.nodeNamed(nodeName) {
            // Bob up and down
            ducky.modelMatrix = float4x4(translationBy: float3(0, 0.015 * sin(time * 5), 0))
        }
    }

    /// Builds the inflatable ducky scene which is a simple node
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

        let ducky = Node(name: nodeName)
        let duckyMaterial = Material()
        let duckyBaseColorTexture = try? textureLoader.newTexture(name: "duckyTexture",
                                                                scaleFactor: 1.0,
                                                                bundle: nil,
                                                                options: options)
        duckyMaterial.baseColorTexture = duckyBaseColorTexture
        duckyMaterial.specularPower = 100
        duckyMaterial.specularColor = float3(0.8, 0.8, 0.8)
        ducky.material = duckyMaterial

        let bobURL = Bundle.main.url(forResource: "ducky", withExtension: "obj")!
        let bobAsset = MDLAsset(url: bobURL, vertexDescriptor: vertexDescriptor, bufferAllocator: bufferAllocator)
        ducky.mesh = try! MTKMesh.newMeshes(asset: bobAsset, device: device).metalKitMeshes.first!

        scene.rootNode.children.append(ducky)
        return scene
    }

}
