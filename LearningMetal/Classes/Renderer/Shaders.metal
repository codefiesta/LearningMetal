//
//  Shaders.metal
//  LearningMetal
//
//  Created by Kevin McKee on 3/17/19.
//  Copyright © 2019 Procore. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

// Basic Struct to match our Swift type
// This is what is passed into the Vertex Shader
struct VertexIn {
    float3 position  [[attribute(0)]];
    float3 normal    [[attribute(1)]];
    float2 textureCoordinates [[attribute(2)]];
};

// What is returned by the Vertex Shader
// This is what is passed into the Fragment Shader
struct VertexOut {
    float4 position [[position]];
    float3 worldNormal;
    float3 worldPosition;
    float2 textureCoordinates;
};

struct Light {
    float3 worldPosition;
    float3 color;
};

struct VertexUniforms {
    float4x4 viewProjectionMatrix;
    float4x4 modelMatrix;
    float3x3 normalMatrix;
};

#define LightCount 3

struct FragmentUniforms {
    float3 cameraWorldPosition;
    float3 ambientLightColor;
    float3 specularColor;
    float specularPower;
    Light lights[LightCount];
};

// The main vertex shader function
vertex VertexOut vertexMain(VertexIn vertexIn [[stage_in]],
                             constant VertexUniforms &uniforms [[buffer(1)]]) {
    VertexOut vertexOut;
    float4 worldPosition = uniforms.modelMatrix * float4(vertexIn.position, 1);
    vertexOut.position = uniforms.viewProjectionMatrix * worldPosition;
    vertexOut.worldPosition = worldPosition.xyz;
    vertexOut.worldNormal = uniforms.normalMatrix * vertexIn.normal;
    vertexOut.textureCoordinates = vertexIn.textureCoordinates;
    return vertexOut;
}

// The primary fragment shader function
fragment float4 fragmentMain(VertexOut fragmentIn [[stage_in]],
                              constant FragmentUniforms &uniforms [[buffer(0)]],
                              texture2d<float, access::sample> baseColorTexture [[texture(0)]],
                              sampler baseColorSampler [[sampler(0)]]) {
    float3 baseColor = baseColorTexture.sample(baseColorSampler, fragmentIn.textureCoordinates).rgb;
    float3 specularColor = uniforms.specularColor;
    
    float3 N = normalize(fragmentIn.worldNormal);
    float3 V = normalize(uniforms.cameraWorldPosition - fragmentIn.worldPosition);
    
    float3 finalColor(0, 0, 0);
    for (int i = 0; i < LightCount; ++i) {
        float3 L = normalize(uniforms.lights[i].worldPosition - fragmentIn.worldPosition.xyz);
        float3 diffuseIntensity = saturate(dot(N, L));
        float3 H = normalize(L + V);
        float specularBase = saturate(dot(N, H));
        float specularIntensity = powr(specularBase, uniforms.specularPower);
        float3 lightColor = uniforms.lights[i].color;
        finalColor += uniforms.ambientLightColor * baseColor +
        diffuseIntensity * lightColor * baseColor +
        specularIntensity * lightColor * specularColor;
    }
    return float4(finalColor, 1);
}


