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
    private var feedbackGenerator : UIImpactFeedbackGenerator? = nil

    required init?(_ view: MTKView) {
        super.init(view)
        
        /// Adds the pan gesture to rotate the Ducky
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)

        /// Adds the move gesture to move the Ducky around
        let moveGesture = UIPanGestureRecognizer(target: self, action: #selector(handleMoveGesture(_:)))
        moveGesture.minimumNumberOfTouches = 2
        view.addGestureRecognizer(moveGesture)

        // Adds the pinch gesture zoom in/out on the Ducky
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        view.addGestureRecognizer(pinchGesture)
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
    
    /// Adds a simple pan gesture to rotate the ducky
    @objc func handlePanGesture(_ gestureRecognizer : UIPanGestureRecognizer) {
        
        guard let scene = scene, let view = gestureRecognizer.view else { return }
        
        let velocity = gestureRecognizer.velocity(in: view)

        let multiplier: Float = 0.0075 // Slows the movement down
        let x = Float(velocity.x).radians * multiplier
        let y = Float(velocity.y).radians * multiplier
        scene.rootNode.modelMatrix.rotate(angle: x, axis: float3(0, 1, 0))
        scene.rootNode.modelMatrix.rotate(angle: y, axis: float3(1, 0, 0))
    }
    
    @objc func handleMoveGesture(_ gestureRecognizer : UIPanGestureRecognizer) {
        guard let scene = scene, let view = gestureRecognizer.view else { return }
        
        let velocity = gestureRecognizer.translation(in: view)
        
        let multiplier: Float = 0.0075 // Slows the movement down
        let x = Float(velocity.x).radians * multiplier
        let y = Float(velocity.y).radians * multiplier * -1
        scene.rootNode.modelMatrix.translate(direction: float3(x, y, 0))
    }
    

    /// Adds a simple pinch gesture to the ducky
    @objc func handlePinchGesture(_ gestureRecognizer : UIPinchGestureRecognizer) {
        guard let scene = scene else { return }
        
        let scale = Float(gestureRecognizer.scale)
        
        switch gestureRecognizer.state {
        case .began:
            feedbackGenerator = UIImpactFeedbackGenerator()
            feedbackGenerator?.prepare()
        case .changed:
            let value: Float = scale > 1 ? 1.02 : 0.98
            scene.rootNode.modelMatrix.scale(axis: float3(value, value, value))

            feedbackGenerator?.impactOccurred()
            feedbackGenerator?.prepare()
        case .cancelled, .ended, .failed:
            feedbackGenerator = nil
        default:
            break
        }
    }
}
