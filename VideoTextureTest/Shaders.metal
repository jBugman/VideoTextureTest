#include <metal_stdlib>
using namespace metal;

struct VertexInOut
{
    float4 m_Position [[position]];
    float2 m_TexCoord [[user(texturecoord)]];
};

vertex VertexInOut texturedQuadVertex(const device packed_float3* pPosition [[ buffer(0) ]],
                                                             uint vid       [[ vertex_id ]])
{
    VertexInOut outVertices;
    outVertices.m_Position = float4(0.8 * pPosition[vid], 1);
    outVertices.m_TexCoord = 0.5 * (outVertices.m_Position.xy + 1);
    return outVertices;
}

fragment half4 texturedQuadFragment(VertexInOut inFrag [[ stage_in ]],
                               texture2d<half>  tex2D  [[ texture(0) ]])
{
    constexpr sampler samplr;
    half4 color = tex2D.sample(samplr, inFrag.m_TexCoord);
    return color;
}