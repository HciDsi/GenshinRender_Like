#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

struct appdate
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
    float2 uv : TEXCOORD0;
    float2 backUV : TEXCOORD1;
};

struct v2f
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD0;
    float2 backUV : TEXCOORD1;
    float3 normalWS : TEXCOORD2;
    float3 bitangentWS : TEXCOORD3;
    float3 tangentWS : TEXCOORD4;
    float3 positionNDC : TEXCOORD5;
    float3 positionWS : TEXCOORD6;
    float3 viewDir : TEXCOORD7;
};

v2f ForwardPassVertex(appdate v)
{
    VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(v.normal, v.tangent);

    v2f o;
    o.positionCS = vertexInput.positionCS;
    o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
    o.backUV =  TRANSFORM_TEX(v.backUV, _BaseMap);
    o.normalWS = normalInput.normalWS;
    o.tangentWS = normalInput.tangentWS;
    o.bitangentWS = normalInput.bitangentWS;
    o.positionNDC = vertexInput.positionNDC;
    o.positionWS = vertexInput.positionWS;
    o.viewDir = GetWorldSpaceNormalizeViewDir(vertexInput.positionWS);

    return o;
}

half4 ForwardPassFragment(v2f i) : SV_TARGET
{
Light mainLight = GetMainLight();
half3 light = SafeNormalize(mainLight.direction);
//half3 N = SafeNormalize(i.normalWS);

half3 F = SafeNormalize( half3(_FaceDirection.x, 0.0, _FaceDirection.z));
half3 L = SafeNormalize( half3(light.x, 0.0, light.z));
half FdotL = dot(F, L);
half FcrossL = cross(F, L).y;

half2 faceUV = i.uv;
faceUV.x =  lerp(faceUV.x, 1.0 - faceUV.x, step(0.0, FcrossL));

half faceShadow = SAMPLE_TEXTURE2D(_FaceLightMap, sampler_FaceLightMap, faceUV).r;
faceShadow =  step(-0.5 * FdotL + 0.5 + _FaceShadowOffset, faceShadow);
half faceMask = SAMPLE_TEXTURE2D(_FaceShadow, sampler_FaceShadow, i.uv).a;
faceShadow = lerp(faceShadow, 1.0, faceMask);

half rampU = smoothstep(0.6, 0.8, step(0.5, faceShadow));
half rampV = 0.5 + 0.3 + 0.05;
half3 diffuse = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, half2(rampU, rampV)).rgb;

half3 finalColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, faceUV).rgb * diffuse;
//finalColor = lerp(_BaseColor, finalColor, step(0.97, faceShadow));

return half4(diffuse,1);
    //return half4(rampU, rampU, rampU, 1);

}