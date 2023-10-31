#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

CBUFFER_START(UnityPerMaterial)

half4 _BaseColor;
half _IsDay;
half _ToonFac;
half _Cull;
half _SrcBlend;
half _DstBlend;
float4  _BaseMap_ST;

half4 _ShadowColor;
half _ShadowOffset;
half _ShadowSmoothness;

half _SpecularSmoothness;
half _NonmetallicIntensity;
half _MetallicIntensty;

half _UseNormal;

half _OutlineWidth;
half _OutlineColor;

CBUFFER_END

TEXTURE2D(_ToonMap);            SAMPLER(sampler_ToonMap); 
TEXTURE2D(_BaseMap);            SAMPLER(sampler_BaseMap);
TEXTURE2D(_LightMap);           SAMPLER(sampler_LightMap);
TEXTURE2D(_ShadowRamp);         SAMPLER(sampler_ShadowRamp);
TEXTURE2D(_NormalMap);          SAMPLER(sampler_NormalMap);
TEXTURE2D(_MetalMap);           SAMPLER(sampler_MetalMap);