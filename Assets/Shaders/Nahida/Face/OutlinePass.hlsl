#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

float4 _OutlineColor;
float _OutlineWidth;

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
};

v2f OutlinePassVertex(appdate v)
{
    VertexPositionInputs positionInput = GetVertexPositionInputs(v.vertex.xyz + v.tangent.xyz * _OutlineWidth * 0.0001);
                //VertexPositionInputs positionInput = GetVertexPositionInputs(v.vertex.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(v.normal, v.tangent);

	            //float z = abs(positionInput.positionVS.z);
	            //float width = _OutlineWidth * saturate(z) * 0.1;
	            //float3 posWS = positionInput.positionWS + width * normalInput.normalWS;
                //float3 posWS = positionInput.positionWS + width * normalInput.tangentWS;

    v2f o = (v2f) 0;
	            //o.pos = TransformWorldToHClip(posWS);
    o.pos = positionInput.positionCS;

    return o;
}

float4 OutlinePassFragment(v2f i) : SV_TARGET
{
    return _OutlineColor;
}