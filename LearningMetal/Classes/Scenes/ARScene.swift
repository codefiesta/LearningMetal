//
//  ARScene.swift
//  LearningMetal
//
//  Created by Kevin McKee on 4/25/19.
//  Copyright © 2019 Procore. All rights reserved.
//

import ARKit
import MetalKit

class ARScene: DefaultSceneRenderer {
    
    let nodeName = "Teapot"
    var session: ARSession?
    var time: Float = 0

    required init?(_ view: MTKView, session: ARSession?) {
        super.init(view)
        self.session = session
        session?.delegate = self
        view.layer.isOpaque = false
        prepareGestures(view)
    }
    
    required init?(_ view: MTKView) {
        fatalError("init(_:) has not been implemented")
    }

    fileprivate func prepareGestures(_ view: MTKView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
    }

    override func update(_ view: MTKView, descriptor: MTLRenderPassDescriptor) {
    }
    
    /// Builds the scene which is a simple node
    override func buildScene() -> Scene? {
        let scene = Scene()
        return scene
    }

    fileprivate func addNode(_ anchor: ARPlaneAnchor) {
        print("Adding node for anchor \(anchor)")
    }
}

extension ARScene {

    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        print("Handling tap")
        guard let frame = session?.currentFrame else { return }
        
        print("Frame \(frame)")
        // Create a transform with a translation of 0.2 meters in front of the camera
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.2
        let transform = simd_mul(frame.camera.transform, translation)
        
        // Add a new anchor to the session
        let anchor = ARAnchor(transform: transform)
        session?.add(anchor: anchor)
    }

}

extension ARScene: ARSessionDelegate {
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        print("🧐 [\(anchors)]")
        for anchor in anchors {
            guard let anchor = anchor as? ARPlaneAnchor else { continue }
            addNode(anchor)
        }
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        
    }
}
