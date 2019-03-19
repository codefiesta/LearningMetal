//
//  Math+Extensions.swift
//  LearningMetal
//
//  Created by Kevin McKee on 3/17/19.
//  Copyright © 2019 Procore. All rights reserved.
//

import simd

extension float4 {

    init(_ v: float3, _ w: Float) {
        self.init(x: v.x, y: v.y, z: v.z, w: w)
    }

    var xyz: float3 {
        return float3(x, y, z)
    }
}

extension float4x4 {

    init(scaleBy s: Float) {
        self.init(float4(s, 0, 0, 0),
                  float4(0, s, 0, 0),
                  float4(0, 0, s, 0),
                  float4(0, 0, 0, 1))
    }
    
    init(rotationAbout axis: float3, by angleRadians: Float) {
        let a = normalize(axis)
        let x = a.x, y = a.y, z = a.z
        let c = cosf(angleRadians)
        let s = sinf(angleRadians)
        let t = 1 - c
        self.init(float4( t * x * x + c,     t * x * y + z * s, t * x * z - y * s, 0),
                  float4( t * x * y - z * s, t * y * y + c,     t * y * z + x * s, 0),
                  float4( t * x * z + y * s, t * y * z - x * s,     t * z * z + c, 0),
                  float4(                 0,                 0,                 0, 1))
    }
    
    init(translationBy t: float3) {
        self.init(float4(   1,    0,    0, 0),
                  float4(   0,    1,    0, 0),
                  float4(   0,    0,    1, 0),
                  float4(t[0], t[1], t[2], 1))
    }
    
    init(perspectiveProjectionFov fovRadians: Float, aspectRatio aspect: Float, nearZ: Float, farZ: Float) {
        let yScale = 1 / tan(fovRadians * 0.5)
        let xScale = yScale / aspect
        let zRange = farZ - nearZ
        let zScale = -(farZ + nearZ) / zRange
        let wzScale = -2 * farZ * nearZ / zRange
        
        let xx = xScale
        let yy = yScale
        let zz = zScale
        let zw = Float(-1)
        let wz = wzScale
        
        self.init(float4(xx,  0,  0,  0),
                  float4( 0, yy,  0,  0),
                  float4( 0,  0, zz, zw),
                  float4( 0,  0, wz,  0))
    }
    
    var normalMatrix: float3x3 {
        let upperLeft = float3x3(self[0].xyz, self[1].xyz, self[2].xyz)
        return upperLeft.transpose.inverse
    }
}

extension Float {

    var radians: Float {
        return (self / 180) * .pi
    }
}

extension float4x4 {

    init(rotationAroundAxis axis: float3, by angle: Float) {
        let unitAxis = normalize(axis)
        let ct = cosf(angle)
        let st = sinf(angle)
        let ci = 1 - ct
        let x = unitAxis.x, y = unitAxis.y, z = unitAxis.z
        self.init(columns:(float4(    ct + x * x * ci, y * x * ci + z * st, z * x * ci - y * st, 0),
                           float4(x * y * ci - z * st,     ct + y * y * ci, z * y * ci + x * st, 0),
                           float4(x * z * ci + y * st, y * z * ci - x * st,     ct + z * z * ci, 0),
                           float4(                  0,                   0,                   0, 1)))
    }
    
    init(perspectiveProjectionRHFovY fovy: Float, aspectRatio: Float, nearZ: Float, farZ: Float) {
        let ys = 1 / tanf(fovy * 0.5)
        let xs = ys / aspectRatio
        let zs = farZ / (nearZ - farZ)
        self.init(columns:(float4(xs,  0, 0,   0),
                           float4( 0, ys, 0,   0),
                           float4( 0,  0, zs, -1),
                           float4( 0,  0, zs * nearZ, 0)))
    }
}
