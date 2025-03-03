#include <metal_stdlib>
using namespace metal;

fragment float4 myWarpShader() {
    return float4(0.0, 1.0, 0.0, 1.0); // Green screen for testing
}
