#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct appdate
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float2 uv : TEXCOORD0;
    float4 tangent : TANGENT;
};

struct v2f
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
};

v2f OutlinePassVertex(appdate v)
{
    VertexPositionInputs positionInput = GetVertexPositionInputs(v.vertex.xyz + v.tangent.xyz * _OutlineWidth * 0.0002);
                //VertexPositionInputs positionInput = GetVertexPositionInputs(v.vertex.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(v.normal, v.tangent);

	            //float z = abs(positionInput.positionVS.z);
	            //float width = _OutlineWidth * saturate(z) * 0.1;
	            //float3 posWS = positionInput.positionWS + width * normalInput.normalWS;
                //float3 posWS = positionInput.positionWS + width * normalInput.tangentWS;

    v2f o = (v2f) 0;
    o.pos = positionInput.positionCS;
    o.uv = TRANSFORM_TEX(v.uv, _BaseMap);

    return o;
}

float4 OutlinePassFragment(v2f i) : SV_TARGET
{
    half4 lightMap = SAMPLE_TEXTURE2D(_LightMap, sampler_LightMap, i.uv);
    int index = 4;
    index = lerp(index, 1, step(0.2, lightMap.a));
    index = lerp(index, 2, step(0.4, lightMap.a));
    index = lerp(index, 0, step(0.6, lightMap.a));
    index = lerp(index, 3, step(0.8, lightMap.a));

    half3 outlineColor = SAMPLE_TEXTURE2D(_ShadowRamp, sampler_ShadowRamp, half2(0.5, index / 10.0 + 0.5 + 0.05));

    return half4(outlineColor, 1);
}