//
//  Camera.swift
//  LearningMetal
//
//  Created by Kevin McKee on 3/17/19.
//  Copyright © 2019 Procore. All rights reserved.
//

import simd

class Camera {

    var fieldOfView: Float = 65.0
    var nearZ: Float = 0.1
    var farZ: Float = 100.0
    
    func projectionMatrix(aspectRatio: Float) -> float4x4 {
        return float4x4(perspectiveProjectionRHFovY: fieldOfView.radians, aspectRatio: aspectRatio, nearZ: nearZ, farZ: farZ)
    }
}
