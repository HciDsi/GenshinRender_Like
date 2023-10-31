Shader "Shader/Hutao"
{
    Properties
    {
        [Header(General)]
        [MainTexture] _BaseMap ("Base Map", 2D) = "while" {} //基础纹理
        [MainColor] _BaseColor ("Base Color", Color) = (1, 1, 1, 1) //基础色
        _ToonFac ("Toon Fac", Range(0, 1)) = 0.5 //卡通纹理混合度
        _ToonMap ("Toon Map", 2D) = "while" {} //卡通纹理
        [ToggleUI] _IsDay ("Is Day", Float) = 1 //是否是白天    
        [Enum(UnityEngie.Rendering.CullMade)] _Cull ("Cull", Float) = 2 //剔除参数
        [Enum(UnityEngie.Rendering.BlendMade)] _SrcBlend ("Src Blend", Float) = 1 //混合参数
        [Enum(UnityEngie.Rendering.BlendMade)] _DstBlend ("Dst Blend", Float) = 0 //混合参数

        [Header(Normal)]
        [Toggle(_NORMAL_MAP)] _UseNormal ("Use Normal", Float) = 0
        _NormalMap ("Normal Map", 2D) = "bump" {}

        [Header(Diffuse)]
        [Toggle(_NOT_HAIR)] _NotHair ("Not Hair", Float) = 0
        _LightMap ("Light Map", 2D) = "while" {} //光照贴图
        _ShadowColor ("Shadow Color", Color) = (1, 1, 1, 1) //阴影颜色
        _ShadowOffset ("Shadow Offset", Range(0, 1)) = 0.3 //阴影偏移量
        _ShadowSmoothness ("Shadow Smoothness", Range(0, 1)) = 0.2 //阴影软化范围
        _ShadowRamp ("Shadow Ramp", 2D) = "white" {} //Ramp图

        [Header(Specular)]
        [Toggle(_USE_SPECULAR)] _UseSpecular ("Use Specular", Float) = 1
        _SpecularSmoothness ("Specular Smoothness", Range(8, 256)) = 8 //高光范围
        _NonmetallicIntensity ("Nonmetallic Intensity", Range(0, 1)) = 0.5 //非金属度
        _MetallicIntensty ("Metallic Intensity", Range(1, 25)) = 5//金属度
        _MetalMap ("Metal Map", 2D) = "white" {} //金属光泽贴图

        [Header(Emission)]
        [Toggle(_EMISSION)] _UseEmission ("Use Emission", Float) = 0
        _EmissionIntensity ("Emission Intensity", Range(0, 1)) = 1

        [Header(Face)]
        [Toggle(_IS_FACE)] _IsFace ("Is Face", Float) = 0 
        _FaceDirection ("Face Direction", Vector) = (0,0,1,0) //面朝方向向量
        _FaceShadowOffset ("Face Shadow Offset", Float) = 0 //面部阴影偏移距离
        _FaceBlushColor ("Face Blush Color", Color) = (1,1,1,1) //
        _FaceBlushStrength ("Face Blush Strength", Float) = 1
        _FaceLightMap ("Face Light Map", 2D) = "white" {} //面部光照贴图
        _FaceShadow ("Face Shadow", 2D) = "white" {} //面部阴影范围

        [Header(Rim Light)]
        [Toggle(_Use_Rim)] _UseRim ("Use Rim", Float) = 0 
        _RimOffset ("Rim Offset", Range(0, 1)) = 0.6 //边缘光宽度
        _RimThreshold ("Rim Threshold", Range(0, 1)) = 1 //边缘光范围
        _RimIntensity ("Rim Intensity", Range(0, 1)) = 1 //边缘光强度
        _RimColor ("Rim Color", Color) = (1, 1, 1, 1) //边缘光颜色

        [Header(Outline)]
        [Toggle(_Use_Outline)] _UseOutline ("Use Outline", Float) = 1
        _OutlineWidth ("Outline Width", Range(0, 1)) = 0.2 //描边宽度
        _OutlineColor ("outline Color", Color) = (0, 0, 0, 0) //描边颜色
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

            Cull [_Cull]
            ZWrite On
            Blend [_SrcBlend] [_DstBlend]

            HLSLPROGRAM

            #pragma shader_feature_local_fragment _NORMAL_MAP
            #pragma shader_feature_local_fragment _NOT_HAIR
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _USE_SPECULAR
            #pragma shader_feature_local_fragment _IS_FACE
            #pragma shader_feature_local_fragment _Use_Rim

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            CBUFFER_START(UnityPerMaterials)

                float4 _BaseMap_ST;
                half4 _BaseColor;
                half _ToonFac;
                half _IsDay;

                half4 _ShadowColor;
                half _ShadowOffset;
                half _ShadowSmoothness;
            
                float _SpecularSmoothness;
                half _NonmetallicIntensity;
                half _MetallicIntensty;

                half _EmissionIntensity;

                half3 _FaceDirection;
                half _FaceShadowOffset;
                half3 _FaceBlushColor;
                half _FaceBlushStrength;

                half _RimOffset;
                half _RimThreshold;
                half _RimIntensity;

            CBUFFER_END

            TEXTURE2D(_BaseMap);
            TEXTURE2D(_NormalMap);
            TEXTURE2D(_ShadowRamp);
            TEXTURE2D(_MetalMap);
            TEXTURE2D(_LightMap);
            TEXTURE2D(_ToonMap);
            TEXTURE2D(_FaceShadow);
            TEXTURE2D(_FaceLightMap);

            SAMPLER(sampler_BaseMap);
            SAMPLER(sampler_NormalMap);
            SAMPLER(sampler_ShadowRamp);
            SAMPLER(sampler_MetalMap);
            SAMPLER(sampler_LightMap);
            SAMPLER(sampler_ToonMap);
            SAMPLER(sampler_FaceShadow);
            SAMPLER(sampler_FaceLightMap);

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 backUV : TEXCOORD1;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 backUV : TEXCOORD1;
                float4 pos : SV_POSITION;
                float3 viewDir : TEXCOORD2;
                float3 normalWS : TEXCOORD3;
                float3 tangentWS : TEXCOORD4;
                float3 bitangentWS : TEXCOORD5;
                float3 positionWS : TEXCOORD6;
                float4 positionNDC : TEXCOORD7;
            };

            v2f vert (appdata v)
            {
                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz); 
                VertexNormalInputs normalInput = GetVertexNormalInputs(v.normal, v.tangent);

                v2f o;
                o.pos = vertexInput.positionCS; //获取裁剪空间顶点坐标
                o.positionWS = vertexInput.positionWS; //获取世界空间顶点坐标
                o.positionNDC = vertexInput.positionNDC; //获取标准化设备坐标的顶点坐标
                o.normalWS = normalInput.normalWS; //获取世界空间法线向量
                o.tangentWS = normalInput.tangentWS; //获取世界空间切线向量
                o.bitangentWS = normalInput.bitangentWS; //获取世界空间副切线向量
                o.viewDir = GetWorldSpaceNormalizeViewDir(o.positionWS); //获取世界空间视线向量
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap); //获取对象UV信息
                o.backUV = TRANSFORM_TEX(v.uv, _BaseMap); //获取世界空间法线向量

                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                #if _NORMAL_MAP //判断是否使用法线贴图
                    half3 bump = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, i.uv)); //获取切线空间的法线贴图信息
                    half3x3 tangentToWorld = half3x3(i.tangentWS, i.bitangentWS, i.normalWS); //获取从切线空间到世界空间的矩阵
                    i.normalWS = TransformTangentToWorld(bump, tangentToWorld, true); //得到世界空间的法线贴图信息
                #endif
                Light mainLight = GetMainLight(); //主光源
                half3 N = SafeNormalize(i.normalWS); //归一化的世界空间法线
                half3 V = SafeNormalize(i.viewDir); //归一化的世界空间视线方向
                half3 L = SafeNormalize(mainLight.direction); //归一化的世界空间主光源方向
                half3 H = SafeNormalize(V + L); //归一化的世界空间半程向量
                half3 normalVS = TransformWorldToViewNormal(N, true); //归一化的观察空间法线
                
                half2 matcapUV = normalVS.xy * 0.5 + 0.5; //以视线空间法线获取一个matcapUV
                half4 lightMap = SAMPLE_TEXTURE2D(_LightMap, sampler_LightMap, i.uv); //获取光照贴图

                //BaseColor
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv); //对主纹理进行采样
                half3 toon = SAMPLE_TEXTURE2D(_ToonMap, sampler_ToonMap, matcapUV); //以matcapUV对卡通纹理进行采样
                half3 albedo = lerp(_BaseColor, _BaseColor.rgb * baseMap.rgb , 1); //将主纹理与基础色混合
                albedo = lerp(albedo, albedo * toon, _ToonFac); ////将基础色与卡通纹理混合

                #if _IS_FACE
                    //baseColor = lerp(baseColor, baseColor * half3(1,0,0), _FaceBlushStrength * baseMap.a); //腮红
                #endif

                //Diffuse
                //获取Ramp的坐标信息
                int index = 4;
                #if _NOT_HAIR
                    index = lerp(index, 1, step(0.2, lightMap.a));
                    index = lerp(index, 3, step(0.8, lightMap.a));
                #endif

                half halfLambert = pow(dot(L, N) * 0.5 + 0.5, 2); //得到半兰伯特法的漫反射参数
                half shadow = 0.0;

                #if _IS_FACE
                    half3 faceDir = half3(_FaceDirection.x, 0.0, _FaceDirection.z); //获取面部向量
                    half3 lightDir = half3(L.x, 0.0, L.z); //获取光照方向向量
                    half FdotL = dot(faceDir, lightDir); //获取光照方向与面部向量的点乘
                    half FcrossL = cross(faceDir, lightDir).y; //获取光照方向与面部向量的朝向

                    half2 faceUV = i.uv;
                    faceUV.x = lerp(faceUV.x, 1 - faceUV.x, step(0, FcrossL)); //获取面部阴影方向用于面部阴影UV
                    half faceshadow = SAMPLE_TEXTURE2D(_FaceLightMap, sampler_FaceLightMap, faceUV); //采样阴影光照贴图
                    shadow = step(-0.5 * FdotL + 0.5, faceshadow); //以兰伯特法对面部阴影采样

                     half faceMask = SAMPLE_TEXTURE2D(_FaceShadow, sampler_FaceShadow, i.uv).a; //获取面部阴影范围 
                     shadow =1 - lerp(shadow, 1.0, faceMask); //对面部阴影范围进行限制

                     index = 3;
                #else
                    shadow = saturate(halfLambert * lightMap.g * 2); //用光照贴图的g通道（ao贴图）获取对象阴影信息
                    shadow = lerp(shadow, 1, step(0.9, lightMap.g)); //对阴影范围进行过滤

                #endif

                //阴影范围
                half rampMax = _ShadowOffset / 2; 
                half rampMin = _ShadowOffset / 2 - _ShadowSmoothness / 2;
                //获取RampUV
                half rampU = smoothstep(rampMin, rampMax, shadow) ;
                half rampV = index / 10.0 + 0.05 + _IsDay * 0.5;
                half2 rampUV = half2(rampU, rampV);

                half3 diffuse = SAMPLE_TEXTURE2D(_ShadowRamp, sampler_ShadowRamp, rampUV);//用RampUV对Ramp采样
                diffuse = lerp(diffuse, 1, step(rampMax, shadow)); //将大于阴影范围的设置为无阴影

                //Specular
                half3 specular = 0;
                #if _USE_SPECULAR
                    half blinnPhone = pow(saturate(dot(N, H)), _SpecularSmoothness);
                    half3 metalMap = SAMPLE_TEXTURE2D(_MetalMap, sampler_MetalMap, matcapUV); //使用matcapUV对金属光泽纹理采样

                    half3 metal = blinnPhone * metalMap * lightMap.b * _MetallicIntensty * 2; //获取金属高光范围
                    half3 nonmetal = lightMap.r * step(1.1 - blinnPhone, lightMap.b) * _NonmetallicIntensity; //获取非金属高光范围
                    specular = lerp(metal, nonmetal, step(0.9, lightMap.r)); //混合金属高光和非金属高光
                #endif
                
                //Emission
                half3 emission = 0;
                #if _EMISSION
                    emission = step(0.5, baseMap.a) * _EmissionIntensity * 10; //通过材质透明度判断材质是否为发光件
                #endif

                //Rim
                half rim = 0;

                #if _Use_Rim
                    half2 screenUV = i.positionNDC.xy / i.positionNDC.w; //通过屏幕顶点坐标获取屏幕UV 
                    half sceneDepth = SampleSceneDepth(screenUV); //获取场景深度
                    half depth = LinearEyeDepth(sceneDepth, _ZBufferParams); //获取观察深度
                    half2 offsetUV = half2(normalVS.x * _RimOffset * 10.0 / _ScreenParams.x, 0.0); //获取边缘光宽度（偏移量）
                    half offsetDepth = SampleSceneDepth(screenUV + offsetUV);
                    half offset = LinearEyeDepth(offsetDepth, _ZBufferParams);

                    rim = smoothstep(0.0, _RimThreshold, offset - depth) * _RimIntensity; //通过偏移量与观察深度的差获取等屏幕距离边缘光
                    rim = rim * pow(saturate(1 - dot(N, V)), 5.0); //软化边缘光
                #endif

                half4 FColor = half4((specular + diffuse + emission) * albedo + rim, 1);

                return  FColor;
            }

            ENDHLSL
            
        }

        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"

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
            Tags {"LightMode" = "SRPDefaultUnlit"}

            Cull Front

            HLSLPROGRAM

            #pragma shader_feature_local_fragment _NOT_HAIR
            #pragma shader_feature_local_fragment _Use_Outline

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"


            CBUFFER_START(UnityPerMaterials)
                half _OutlineWidth;
                half4 _OutlineColor;
                half4 _LightMap_ST;
            CBUFFER_END

            TEXTURE2D(_LightMap);
            TEXTURE2D(_ShadowRamp);

            SAMPLER(sampler_LightMap);
            SAMPLER(sampler_ShadowRamp);

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            v2f vert(appdata v) 
            {
                //获取沿平滑法线（储存在切线中）方向偏移的顶点信息
                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz + v.tangent * _OutlineWidth * 0.002);//获取沿平滑法线（储存在切线中）方向偏移的顶点信息
                
                v2f o;
                o.pos = vertexInput.positionCS;
                o.uv = TRANSFORM_TEX(v.uv, _LightMap);

                return o;
            }

            half4 frag(v2f i) : SV_TARGET
            {
                half4 lightMap = SAMPLE_TEXTURE2D(_LightMap, sampler_LightMap, i.uv);

                int index = 4;
                #if  _NOT_HAIR
                    index = lerp(index, 1, step(0.2, lightMap.a));
                    index = lerp(index, 3, step(0.8, lightMap.a));
                #endif

                half4 FColor = 0;

                #if  _Use_Outline
                    FColor = SAMPLE_TEXTURE2D(_ShadowRamp, sampler_ShadowRamp, half2(0.75, index / 10.0 + 0.005 + 0.5));
                #endif
                
                return 0; //输出描边颜色
            }

            ENDHLSL
        }
    }
}
