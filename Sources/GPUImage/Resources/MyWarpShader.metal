#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 textureCoordinate [[user(texcoord)]];
};

// ✅ Convert to a fragment shader instead of a compute kernel
fragment float4 myWarpShader(VertexOut in [[stage_in]],
                             texture2d<float> inputTexture [[texture(0)]],
                             constant float2 &warpCenter [[buffer(0)]],
                             constant float &warpRadius [[buffer(1)]],
                             constant float &warpStrength [[buffer(2)]]) {
    
    float2 uv = in.textureCoordinate;
    float2 centerUV = warpCenter;
    
    // Calculate distance from warp center
    float2 offset = uv - centerUV;
    float dist = length(offset);

    // Apply warp effect within radius
    if (dist < warpRadius) {
        float strengthFactor = exp(-dist * dist / (warpRadius * 0.5)) * warpStrength;
        offset *= (1.0 + strengthFactor);
    }

    float2 warpedUV = centerUV + offset;
    warpedUV = clamp(warpedUV, 0.0, 1.0); // Prevents texture out-of-bounds access

    return inputTexture.sample(sampler(coord::normalized), warpedUV);
}
