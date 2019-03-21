//
//  Math+Extensions.swift
//  LearningMetal
//
//  Created by Kevin McKee on 3/17/19.
//  Copyright © 2019 Procore. All rights reserved.
//

import simd

extension Float {
    
    var radians: Float {
        return (self / 180) * .pi
    }
}

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

extension matrix_float4x4 {
    
    init(degreesFov: Float, aspectRatio: Float, nearZ: Float, farZ: Float) {
        let fov = degreesFov.radians
        
        let y = 1 / tan(fov * 0.5)
        let x = y / aspectRatio
        let z1 = farZ / (nearZ - farZ)
        let w = (z1 * nearZ)
        
        self.init(columns: (
            float4(x,0,0,0),
            float4(0,y,0,0),
            float4(0,0,z1,-1),
            float4(0,0,w,0)
        ))
    }
    
    mutating func scale(axis: float3) {
        var result = matrix_identity_float4x4
        
        let x,y,z :Float
        (x,y,z) = (axis.x,axis.y,axis.z)
        
        result.columns = (
            float4(x,0,0,0),
            float4(0,y,0,0),
            float4(0,0,z,0),
            float4(0,0,0,1)
        )
        
        self = matrix_multiply(self, result)
    }
    
    mutating func rotate(angle: Float, axis: float3) {
        var result = matrix_identity_float4x4
        
        let x,y,z :Float
        (x,y,z) = (axis.x,axis.y,axis.z)
        let c: Float = cos(angle)
        let s: Float = sin(angle)
        
        let mc: Float = (1 - c)
        
        let r1c1 = x * x * mc + c
        let r2c1 = x * y * mc + z * s
        let r3c1 = x * z * mc - y * s
        let r4c1: Float = 0.0
        
        let r1c2 = y * x * mc - z * s
        let r2c2 = y * y * mc + c
        let r3c2 = y * z * mc + x * s
        let r4c2: Float = 0.0
        
        let r1c3 = z * x * mc + y * s
        let r2c3 = z * y * mc - x * s
        let r3c3 = z * z * mc + c
        let r4c3: Float = 0.0
        
        let r1c4: Float = 0.0
        let r2c4: Float = 0.0
        let r3c4: Float = 0.0
        let r4c4: Float = 1.0
        
        result.columns = (
            float4(r1c1,r2c1,r3c1,r4c1),
            float4(r1c2,r2c2,r3c2,r4c2),
            float4(r1c3,r2c3,r3c3,r4c3),
            float4(r1c4,r2c4,r3c4,r4c4)
        )
        
        self = matrix_multiply(self, result)
    }
    
    mutating func translate(direction: float3) {
        var result = matrix_identity_float4x4
        
        let x,y,z :Float
        (x,y,z) = (direction.x,direction.y,direction.z)
        
        result.columns = (
            float4(1,0,0,0),
            float4(0,1,0,0),
            float4(0,0,1,0),
            float4(x,y,z,1)
        )
        
        self = matrix_multiply(self, result)
    }
}
