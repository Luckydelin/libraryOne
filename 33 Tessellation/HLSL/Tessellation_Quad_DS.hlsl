#include "Tessellation.hlsli"

[domain("quad")]
float4 DS(QuadPatchTess patchTess,
    float2 uv : SV_DomainLocation,
    const OutputPatch<HullOut, 4> quad) : SV_POSITION
{
    float r = quad[0].PosL.w;
    float R = quad[1].PosL.w;
    
    float3 p0 = quad[0].PosL.xyz;
    float3 p1 = quad[1].PosL.xyz;
    float3 p2 = quad[2].PosL.xyz;
    float3 p3 = quad[3].PosL.xyz;
    float3 center = (p1 + p2 + p3 + p0) * 0.25;
    
    float3 p;
    
    p -= center;
    float pi = 3.14159256;
    uv = uv*2*pi;
    p = float3(cos(uv.x) * (r * cos(uv.y) + R * 5), sin(uv.x) * (r * cos(uv.y) + R * 5), r * sin(uv.y));
    
    p += center;
    
    float4 posH = mul(float4(p, 1.0f), g_WorldViewProj);
    
    return posH;
}
