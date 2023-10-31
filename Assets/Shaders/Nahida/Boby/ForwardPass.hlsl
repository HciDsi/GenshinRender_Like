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
    #if _NORMAL_MAP
        half3x3 tangentToWorld = half3x3(i.tangentWS, i.bitangentWS, i.normalWS);
        half3 bump = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, i.uv));
        i.normalWS = TransformTangentToWorld(bump, tangentToWorld, true);
    #endif
    Light mainLight = GetMainLight();
    half3 L = SafeNormalize(mainLight.direction);
    half3 N = SafeNormalize(i.normalWS);
    half3 V = SafeNormalize(i.viewDir);
    half3 H = SafeNormalize(L + V);

    half2 matcapUV = SafeNormalize(mul((half3x3)UNITY_MATRIX_V, N)).xy * 0.5 + 0.5;
    half3 toonColor = SAMPLE_TEXTURE2D(_ToonMap, sampler_ToonMap, matcapUV);
    half3 baseColor =_BaseColor.rgb;
    half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
    baseColor = lerp(baseColor, _ShadowColor * baseColor, _ToonFac);
    baseColor = lerp(baseColor, baseMap.rgb  * baseColor, 1);
    //baseColor = lerp(baseColor, toonColor * baseColor, _ToonFac);

    //Diffuse
    half4 lightMap = SAMPLE_TEXTURE2D(_LightMap, sampler_LightMap, i.uv);
    half halfLambert = pow(0.5 + 0.5 * dot(N, L), 2);
    half shadow = saturate(halfLambert * lightMap.g * 2.0);
    shadow =lerp(shadow, 1,  step(0.9, lightMap.g));

    int index = 4;
    index = lerp(index, 1, step(0.2, lightMap.a));
    index = lerp(index, 2, step(0.4, lightMap.a));
    index = lerp(index, 0, step(0.6, lightMap.a));
    index = lerp(index, 3, step(0.8, lightMap.a));

    half rampV = index / 10.0 + _IsDay * 0.5 + 0.05;
    half rangeMax = 0.5 + _ShadowOffset;
    half rangeMin = 0.5 + _ShadowOffset - _ShadowSmoothness;
    half rampU = smoothstep(rangeMin, rangeMax, shadow);
    half2 rampUV = half2(rampU , rampV);
    half3 diffuse = SAMPLE_TEXTURE2D(_ShadowRamp, sampler_ShadowRamp, rampUV);
    diffuse  = lerp(diffuse, 1, step(rangeMax, shadow));

    //Specular
    half blinnPhone = pow(saturate(dot(N, H)), _SpecularSmoothness);
    half3 metalMap = SAMPLE_TEXTURE2D(_MetalMap, sampler_MetalMap, matcapUV).rgb;

    half3 nonmetal = lightMap.r * step(1.1 - blinnPhone, lightMap.b) * _NonmetallicIntensity;
    half3 metal = metalMap * lightMap.b * blinnPhone * baseColor * _MetallicIntensty * 10;
    half3 specular = lerp(metal, nonmetal, step(0.9, lightMap.r));

    //Emission
    half3 emission = step(0.5, baseMap.a) * 50;

    half3 finalColor = baseColor * (diffuse + specular + emission);

    return half4(finalColor,1);
}