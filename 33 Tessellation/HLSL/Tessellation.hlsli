
cbuffer CBChangesEveryDraw : register(b0)
{
    float4 g_Color;
}

cbuffer CBChangesEveryFrame : register(b1)
{
    matrix g_WorldViewProj;
    float g_InvScreenHeight;      // 1.0f / Height
}

cbuffer CBPatchTess : register(b2)
{
    float3 g_TriEdgeTess;
    float  g_TriInsideTess;
    
    float4 g_QuadEdgeTess;
    float2 g_QuadInsideTess;
    
    float2 g_IsolineEdgeTess;
}



struct VertexOut
{
    float4 PosL : POSITION;
};

typedef VertexOut HullOut;

struct GeometryOut
{
    float4 PosH : SV_Position;
};

struct IsolinePatchTess
{
    float EdgeTess[2] : SV_TessFactor;
    
    // 可以在下面为每个面片附加所需的额外信息
};

struct TriPatchTess
{
    float EdgeTess[3] : SV_TessFactor;
    float InsideTess : SV_InsideTessFactor;
    
    // 可以在下面为每个面片附加所需的额外信息
};

struct QuadPatchTess
{
    float EdgeTess[4] : SV_TessFactor;
    float InsideTess[2] : SV_InsideTessFactor;
    
    // 可以在下面为每个面片附加所需的额外信息
};


IsolinePatchTess IsolineConstantHS(InputPatch<VertexOut, 4> patch, uint patchID : SV_PrimitiveID)
{
    IsolinePatchTess pt;
    
    pt.EdgeTess[0] = g_IsolineEdgeTess[0];  // 未知
    pt.EdgeTess[1] = g_IsolineEdgeTess[1];  // 段数
    
    return pt;
}

TriPatchTess TriConstantHS(InputPatch<VertexOut, 3> patch, uint patchID : SV_PrimitiveID)
{
    TriPatchTess pt;
    
    pt.EdgeTess[0] = g_TriEdgeTess[0];
    pt.EdgeTess[1] = g_TriEdgeTess[1];
    pt.EdgeTess[2] = g_TriEdgeTess[2];
    pt.InsideTess = g_TriInsideTess;
    
    return pt;
}

QuadPatchTess QuadConstantHS(InputPatch<VertexOut,4> patch, uint patchID : SV_PrimitiveID)
{
    QuadPatchTess pt;
    
    pt.EdgeTess[0] = g_QuadEdgeTess[0];
    pt.EdgeTess[1] = g_QuadEdgeTess[0];
    pt.EdgeTess[2] = g_QuadEdgeTess[0];
    pt.EdgeTess[3] = g_QuadEdgeTess[0];
    pt.InsideTess[0] = g_QuadInsideTess[0];
    pt.InsideTess[1] = g_QuadInsideTess[0];
    
    return pt;
}

QuadPatchTess QuadPatchConstantHS(InputPatch<VertexOut, 16> patch, uint patchID : SV_PrimitiveID)
{
    QuadPatchTess pt;
    
    pt.EdgeTess[0] = g_QuadEdgeTess[1];
    pt.EdgeTess[1] = g_QuadEdgeTess[0];
    pt.EdgeTess[2] = g_QuadEdgeTess[0];
    pt.EdgeTess[3] = g_QuadEdgeTess[0];
    pt.InsideTess[0] = g_QuadInsideTess[0];
    pt.InsideTess[1] = g_QuadInsideTess[0];
    
    return pt;
}

float4 BernsteinBasis(float t)
{
    float invT = 1.0f - t;
    
    return float4(
        invT * invT * invT,         // B_{0}^{3}(t)= (1-t)^3
        3.0f * t * invT * invT,     // B_{1}^{3}(t)= 3t(1-t)^2
        3.0f * t * t * invT,        // B_{2}^{3}(t)= 3t^2(1-t)
        t * t * t);                 // B_{3}^{3}(t)= t^3
}

float4 dBernsteinBasis(float t)
{
    float invT = 1.0f - t;
    
    return float4(
        -3 * invT * invT,                   // B_{0}^{3}'(t)= -3(1-t)^2
        3.0f * invT * invT - 6 * t * invT,  // B_{1}^{3}'(t)= 3(1-t)^2 - 6t(1-t)
        6 * t * invT - 3 * t * t,           // B_{2}^{3}'(t)= 6t(1-t) - 3t^2
        3 * t * t);                         // B_{3}^{3}'(t)= 3t^2
}



