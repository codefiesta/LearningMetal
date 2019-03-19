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
    
    var rootNode = Node(name: Scene.rootName)
    var ambientLightColor = float3(0, 0, 0)
    var lights = [Light]()
        
    func nodeNamed(_ name: String) -> Node? {
        if rootNode.name == name {
            return rootNode
        } else {
            return rootNode.child(name)
        }
    }
}
