//
//  DuckyGestures.swift
//  LearningMetal
//
//  Created by Kevin McKee on 3/19/19.
//  Copyright © 2019 Procore. All rights reserved.
//

import MetalKit

/// Ducky with gesture interaction
class DuckyGesturesScene: DuckyScene {
    
    private var growingColor: Bool = true
    private var colorChannel: Int = 0
    private var colorChannels: [Float] = [1.0, 0.0, 0.0, 1.0] // RGBA
    private let dynamicColorRate: Float = 0.0125

    required init?(_ view: MTKView) {
        super.init(view)
        
        /// Adds the pan gesture to the Ducky
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    override func update(_ view: MTKView, descriptor: MTLRenderPassDescriptor) {

        descriptor.colorAttachments[0].clearColor = generateColor()
        cameraWorldPosition = float3(0, 0, 5)
        
        viewMatrix = float4x4(translationBy: -cameraWorldPosition) * float4x4(rotationAbout: float3(1, 0, 0), by: .pi / 6)
        
        let aspectRatio = Float(view.drawableSize.width / view.drawableSize.height)
        projectionMatrix = float4x4(perspectiveProjectionFov: Float.pi / 6, aspectRatio: aspectRatio, nearZ: 0.1, farZ: 100)
    }

    // Cycles through colors
    fileprivate func generateColor() -> MTLClearColor {
        
        if growingColor {
            let index = (colorChannel + 1) % 3
            colorChannels[index] += dynamicColorRate
            if colorChannels[index] >= 1 {
                growingColor = false
                colorChannel = index
            }
        } else {
            let index = (colorChannel + 2) % 3
            colorChannels[index] -= dynamicColorRate
            if colorChannels[index] <= 0 {
                growingColor = true
            }
        }
        
        let red = Double(colorChannels[0])
        let green = Double(colorChannels[1])
        let blue = Double(colorChannels[2])
        return MTLClearColorMake(red, green, blue, 1.0)
    }
}

extension DuckyGesturesScene {
    
    /// Adds a simple pan gesture to the ducky
    @objc func handlePanGesture(_ gestureRecognizer : UIPanGestureRecognizer) {
        
        guard let scene = scene, let view = gestureRecognizer.view else { return }
        
        let translation = gestureRecognizer.translation(in: view)
        
        let multiplier: Float = 0.25 // Slows the movement down
        let x = Float(translation.x).radians * multiplier
        let y = Float(translation.y).radians * multiplier
        
        let xRotation = float4x4(rotationAbout: float3(0, 1, 0), by: x)
        let yRotation = float4x4(rotationAbout: float3(1, 0, 0), by: y)
        scene.rootNode.modelMatrix = xRotation * yRotation // Turntable
    }
}
