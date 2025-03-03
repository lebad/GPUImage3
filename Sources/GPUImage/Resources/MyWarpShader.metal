#include <metal_stdlib>
using namespace metal;

// Warp Shader - Distorts pixels around the center
kernel void myWarpShader(
    texture2d<float, access::read> inputTexture [[texture(0)]],
    texture2d<float, access::write> outputTexture [[texture(1)]],
    constant float2 &warpCenter [[buffer(0)]],
    constant float &warpRadius [[buffer(1)]],
    constant float &warpStrength [[buffer(2)]],
    uint2 gid [[thread_position_in_grid]]
) {
    float2 uv = float2(gid) / float2(outputTexture.get_width(), outputTexture.get_height());
    float2 centerUV = warpCenter / float2(outputTexture.get_width(), outputTexture.get_height());

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

    outputTexture.write(inputTexture.read(uint2(warpedUV * float2(inputTexture.get_width(), inputTexture.get_height()))), gid);
}
