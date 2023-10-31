#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

CBUFFER_START(UnityPerMaterial)

    half4 _BaseColor;
    half _Cull;
    half _SrcBlend;
    half _DstBlend;
    float4  _BaseMap_ST;

    half4   _FaceDirection;
    half    _FaceShadowOffset;
    half4   _FaceBlushColor;
    half    _FaceBlushStrength;
CBUFFER_END

TEXTURE2D(_BaseMap);            SAMPLER(sampler_BaseMap);
TEXTURE2D(_RampMap);            SAMPLER(sampler_RampMap);
TEXTURE2D(_FaceLightMap);       SAMPLER(sampler_FaceLightMap);
TEXTURE2D(_FaceShadow);         SAMPLER(sampler_FaceShadow);