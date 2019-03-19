//
//  Node.swift
//  LearningMetal
//
//  Created by Kevin McKee on 3/17/19.
//  Copyright © 2019 Procore. All rights reserved.
//

import ModelIO
import MetalKit
import simd

struct Light {
    var worldPosition = float3(0, 0, 0)
    var color = float3(0, 0, 0)
}

class Material {
    var specularColor = float3(1, 1, 1)
    var specularPower = Float(1)
    var baseColorTexture: MTLTexture?
}

class Node {

    let identifier: UUID
    var name: String
    weak var parent: Node?
    var children = [Node]()
    var modelMatrix = matrix_identity_float4x4
    var mesh: MTKMesh?
    var material = Material()

    // Transforms
    var transform: float4x4

    var worldTransform: float4x4 {
        guard let parent = parent else { return transform }
        return parent.worldTransform * transform
    }

    var boundingSphere = BoundingSphere(center: float3(x: 0, y: 0, z: 0), radius: 0)

    init(name: String) {
        self.identifier = UUID()
        self.name = name
        self.transform = matrix_identity_float4x4
    }
    
    /// Recursively finds the first child or descendant with the specified name
    func child(_ name: String) -> Node? {
        for node in children {
            if node.name == name {
                return node
            } else if let grandChild = node.child(name) {
                return grandChild
            }
        }
        return nil
    }
}

extension Node {
    
    /// Returns the farthest descendant in the node tree that contains the intersects the ray (including itself).
    func hitTest(_ ray: Ray) -> Node? {
        return nil
    }
}

