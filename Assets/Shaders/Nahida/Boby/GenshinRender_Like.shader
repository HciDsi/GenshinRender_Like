Shader "Shader/GenshinRender_Like_Boby"
{
    Properties
    {
        [Header(General)]
        [MainTexture] _BaseMap ("Base Map", 2D) = "while" {}
        [MainColor] _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _ToonFac ("Toon Fac", Range(0, 1)) = 0.5
        _ToonMap ("Toon Map", 2D) = "while" {}
        [ToggleUI] _IsDay ("Is Day", Float) = 1     
        [Enum(UnityEngie.Rendering.CullMade)] _Cull ("Cull", Float) = 2
        [Enum(UnityEngie.Rendering.BlendMade)] _SrcBlend ("Src Blend", Float) = 1
        [Enum(UnityEngie.Rendering.BlendMade)] _DstBlend ("Dst Blend", Float) = 0

        [Header(Normal)]
        [Toggle(_NORMAL_MAP)] _UseNormal ("Use Normal", Float) = 0
        _NormalMap ("Normal Map", 2D) = "bump" {}

        [Header(Diffuse)]
        _LightMap ("Light Map", 2D) = "while" {}
        _ShadowColor ("Shadow Color", Color) = (1, 1, 1, 1)
        _ShadowOffset ("Shadow Offset", Range(0, 1)) = 0.2
        _ShadowSmoothness ("Shadow Smoothness", Range(0, 0.5)) = 0.5
        _ShadowRamp("Shadow Ramp", 2D) = "white" {}

        [Header(Specular)]
        _SpecularSmoothness ("Specular Smoothness", Range(8, 256)) = 8
        _NonmetallicIntensity ("Nonmetallic Intensity", Range(0, 1)) = 0.5
        _MetallicIntensty ("Metallic Intensity", Range(1, 25)) = 5
        _MetalMap("Metal Map", 2D) = "white" {}

        [Header(Outline)]
        _OutlineWidth ("Outline Width", Range(0, 15)) = 5
        _OutlineColor ("outline Color", Color) = (0, 0, 0, 0)
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Lit"
            "IgnoreProjector" = "True"
        }


        Pass
        {
            Name "Forward"
            Tags {"LightMode"="UniversalForward"}

            Cull[_Cull]
            ZWrite On
            Blend[_SrcBlend][_DstBlend]

            HLSLPROGRAM

            #pragma shader_feature_local_fragment _NORMAL_MAP

            #pragma vertex ForwardPassVertex
            #pragma fragment ForwardPassFragment
            
            #include "Input.hlsl"
            #include "ForwardPass.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask R
            Cull[_Cull]

            HLSLPROGRAM

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "DepthNormals"
            Tags{"LightMode" = "DepthNormals"}

            ZWrite On
            Cull[_Cull]

            HLSLPROGRAM

            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitDepthNormalsPass.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "Outline"
            Tags{"LightMode" = "SRPDefaultUnlit"}
            Cull Front
            
            HLSLPROGRAM

            #pragma vertex OutlinePassVertex
            #pragma fragment OutlinePassFragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            #include "Input.hlsl"
            #include "OutlinePass.hlsl"

            ENDHLSL
        }

    }
}
