//
//  Scene.swift
//  LearningMetal
//
//  Created by Kevin McKee on 3/17/19.
//  Copyright © 2019 Procore. All rights reserved.
//
import simd
import UIKit

// Holds the node tree strucure used to render scene data
class Scene {

    private static let rootName = "Root"
    
    var camera = SceneCamera()
    var rootNode = Node(name: Scene.rootName)
    var ambientLightColor = float3(0, 0, 0)
    var lights = [Light]()
    
    var xAngle: Float = 0
    var yAngle: Float = 0
    var zAngle: Float = 0
    
    func nodeNamed(_ name: String) -> Node? {
        if rootNode.name == name {
            return rootNode
        } else {
            return rootNode.child(name)
        }
    }

    /// Returns the farthest descendant in the node tree that contains a specified point.
    func hitTest(at point: CGPoint, in bounds: CGRect) -> Node? {
        
//        CGFloat scl = tap.view.contentScaleFactor;
//        CGPoint p = [tap locationInView:tap.view];
//        [_renderer pickNodeAtPixelInViewport:CGPointMake(p.x * scl, p.y * scl)];

//        let width = Float(bounds.size.width)
//        let height = Float(bounds.size.height)
//        let aspectRatio = width / height
//        
//        let projectionMatrix = camera.projectionMatrix(aspectRatio: aspectRatio)
//        let inverseProjectionMatrix = projectionMatrix.inverse
//        
//        let viewMatrix = cameraNode.worldTransform.inverse
//        let inverseViewMatrix = viewMatrix.inverse
//        
//        let clipX = (2 * Float(point.x)) / width - 1
//        let clipY = 1 - (2 * Float(point.y)) / height
//        let clipCoords = float4(clipX, clipY, 0, 1) // Assume clip space is hemicube, -Z is into the screen
//        
//        var eyeRayDir = inverseProjectionMatrix * clipCoords
//        eyeRayDir.z = -1
//        eyeRayDir.w = 0
//        
//        var worldRayDir = (inverseViewMatrix * eyeRayDir).xyz

        return nil
//        let ray = Ray(origin: point, direction: 0)
//        return rootNode.hitTest(ray)
    }
}
