#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct RefractionParams {
    float2 viewSize;
    float2 shapeSize;
    float4 cornerRadii;
    float refractionHeight;
    float refractionAmount;
    float depthEffect;
};

struct DispersionParams {
    float2 viewSize;
    float2 shapeSize;
    float4 cornerRadii;
    float dispersionHeight;
    float dispersionAmount;
};

vertex VertexOut vertex_main(const device float4* vertices [[buffer(0)]],
                             uint vid [[vertex_id]]) {
    VertexOut out;
    out.position = float4(vertices[vid].xy, 0.0, 1.0);
    out.texCoord = vertices[vid].zw;
    return out;
}

inline float radiusAt(float2 coord, float4 radii) {
    if (coord.x >= 0.0) {
        if (coord.y <= 0.0) return radii.z;
        else return radii.y;
    } else {
        if (coord.y <= 0.0) return radii.w;
        else return radii.x;
    }
}

inline float sdRoundedRectangle(float2 coord, float2 halfSize, float4 radii) {
    float r = radiusAt(coord, radii);
    float2 innerHalfSize = halfSize - float2(r);
    float2 cornerCoord = abs(coord) - innerHalfSize;
    float2 mx = max(cornerCoord, float2(0.0));
    float outside = length(mx) - r;
    float inside = min(max(cornerCoord.x, cornerCoord.y), 0.0);
    return outside + inside;
}

inline float2 gradSdRoundedRectangle(float2 coord, float2 halfSize, float4 radii) {
    float r = radiusAt(coord, radii);
    float2 innerHalfSize = halfSize - float2(r);
    float2 cornerCoord = abs(coord) - innerHalfSize;
    
    float insideCorner = step(0.0, min(cornerCoord.x, cornerCoord.y));
    float xMajor = step(cornerCoord.y, cornerCoord.x);
    float2 gradEdge = float2(xMajor, 1.0 - xMajor);
    float2 gradCorner = (length(cornerCoord) > 0.0001) ? normalize(cornerCoord) : float2(0.0, 0.0);
    float2 mixed = mix(gradEdge, gradCorner, insideCorner);
    return sign(coord) * mixed;
}

inline float circleMap(float x) {
    float v = 1.0 - sqrt(max(0.0, 1.0 - x * x));
    return v;
}

fragment float4 roundedRectRefractionFragment(VertexOut in [[stage_in]],
                                              texture2d<float> inputTexture [[texture(0)]],
                                              sampler samp [[sampler(0)]],
                                              constant RefractionParams& params [[buffer(1)]])
{
    float2 viewSize = params.viewSize;
    float2 halfSize = params.shapeSize * 0.5;
    float2 positionPixels = in.texCoord * viewSize;
    float2 center = viewSize * 0.5;
    float2 centeredCoord = positionPixels - center;
    
    float sd = sdRoundedRectangle(centeredCoord, halfSize, params.cornerRadii);
    
    if (-sd >= params.refractionHeight) {
        return inputTexture.sample(samp, in.texCoord);
    }
    
    sd = min(sd, 0.0);
    
    float4 maxGradRadius = float4(min(halfSize.x, halfSize.y));
    float4 gradRadius = min(params.cornerRadii * 1.5, maxGradRadius);
    float2 normal = gradSdRoundedRectangle(centeredCoord, halfSize, gradRadius);
    
    float t = clamp(-sd / params.refractionHeight, 0.0, 1.0);
    float refractedDistance = circleMap(1.0 - t) * params.refractionAmount;
    
    float2 radial = (length(centeredCoord) > 0.0001) ? normalize(centeredCoord) : float2(0.0, 0.0);
    float2 refractedDirection = normalize(normal + params.depthEffect * radial);
    
    float2 refractedPixel = positionPixels + refractedDistance * refractedDirection;
    float2 refractedUV = refractedPixel / viewSize;
    
    float2 clampedUV = clamp(refractedUV, 0.0, 1.0);
    return inputTexture.sample(samp, clampedUV);
}

fragment float4 roundedRectDispersionFragment(VertexOut in [[stage_in]],
                                              texture2d<float> inputTexture [[texture(0)]],
                                              sampler samp [[sampler(0)]],
                                              constant DispersionParams& params [[buffer(1)]])
{
    float2 viewSize = params.viewSize;
    float2 halfSize = params.shapeSize * 0.5;
    float2 positionPixels = in.texCoord * viewSize;
    float2 center = viewSize * 0.5;
    float2 centeredCoord = positionPixels - center;

    float sd = sdRoundedRectangle(centeredCoord, halfSize, params.cornerRadii);

    if (-sd >= params.dispersionHeight) {
        return inputTexture.sample(samp, in.texCoord);
    }

    sd = min(sd, 0.0);

    float dispersionDistance = circleMap(1.0 - clamp(-sd / params.dispersionHeight, 0.0, 1.0)) * params.dispersionAmount;
    if (dispersionDistance < 2.0) {
        return inputTexture.sample(samp, in.texCoord);
    }

    float4 maxGradRadius = float4(min(halfSize.x, halfSize.y));
    float4 gradRadius = min(params.cornerRadii * 1.5, maxGradRadius);
    float2 normal = gradSdRoundedRectangle(centeredCoord, halfSize, gradRadius);
    if (length(normal) < 1e-5) {
        normal = float2(0.0, 1.0);
    }
    float2 tangent = float2(normal.y, -normal.x);

    float4 dispersedColor = float4(0.0);
    float4 weight = float4(0.0);

    float maxI = min(dispersionDistance, 20.0);

    for (int i = 0; i < 20; ++i) {
        float t = float(i) / maxI;
        if (t > 1.0) break;

        float2 samplePixel = positionPixels + tangent * (t - 0.5) * dispersionDistance;
        float2 sampleUV = samplePixel / viewSize;

        sampleUV = clamp(sampleUV, 0.0, 1.0);
        float4 color = inputTexture.sample(samp, sampleUV);

        float rMask = step(0.5, t);
        float gMask = step(0.25, t) * step(t, 0.75);
        float bMask = step(t, 0.5);
        float aMask = rMask + gMask + bMask;
        float4 mask = float4(rMask, gMask, bMask, aMask);

        dispersedColor += color * mask;
        weight += mask;
    }

    float4 safeWeight = max(weight, float4(1e-6));
    float4 result = dispersedColor / safeWeight;

    result.a = clamp(result.a, 0.0, 1.0);

    return result;
}
