//
//  SceneRenderer.swift
//  LearningMetal
//
//  Created by Kevin McKee on 3/17/19.
//  Copyright © 2019 Procore. All rights reserved.
//

import MetalKit

protocol SceneRenderer: MTKViewDelegate {
    init?(_ view: MTKView)
}
