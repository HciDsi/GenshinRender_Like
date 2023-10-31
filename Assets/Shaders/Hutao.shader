Shader "Shader/Hutao"
{
    Properties
    {
        [Header(General)]
        [MainTexture] _BaseMap ("Base Map", 2D) = "while" {} //��������
        [MainColor] _BaseColor ("Base Color", Color) = (1, 1, 1, 1) //����ɫ
        _ToonFac ("Toon Fac", Range(0, 1)) = 0.5 //��ͨ�����϶�
        _ToonMap ("Toon Map", 2D) = "while" {} //��ͨ����
        [ToggleUI] _IsDay ("Is Day", Float) = 1 //�Ƿ��ǰ���    
        [Enum(UnityEngie.Rendering.CullMade)] _Cull ("Cull", Float) = 2 //�޳�����
        [Enum(UnityEngie.Rendering.BlendMade)] _SrcBlend ("Src Blend", Float) = 1 //��ϲ���
        [Enum(UnityEngie.Rendering.BlendMade)] _DstBlend ("Dst Blend", Float) = 0 //��ϲ���

        [Header(Normal)]
        [Toggle(_NORMAL_MAP)] _UseNormal ("Use Normal", Float) = 0
        _NormalMap ("Normal Map", 2D) = "bump" {}

        [Header(Diffuse)]
        [Toggle(_NOT_HAIR)] _NotHair ("Not Hair", Float) = 0
        _LightMap ("Light Map", 2D) = "while" {} //������ͼ
        _ShadowColor ("Shadow Color", Color) = (1, 1, 1, 1) //��Ӱ��ɫ
        _ShadowOffset ("Shadow Offset", Range(0, 1)) = 0.3 //��Ӱƫ����
        _ShadowSmoothness ("Shadow Smoothness", Range(0, 1)) = 0.2 //��Ӱ����Χ
        _ShadowRamp ("Shadow Ramp", 2D) = "white" {} //Rampͼ

        [Header(Specular)]
        [Toggle(_USE_SPECULAR)] _UseSpecular ("Use Specular", Float) = 1
        _SpecularSmoothness ("Specular Smoothness", Range(8, 256)) = 8 //�߹ⷶΧ
        _NonmetallicIntensity ("Nonmetallic Intensity", Range(0, 1)) = 0.5 //�ǽ�����
        _MetallicIntensty ("Metallic Intensity", Range(1, 25)) = 5//������
        _MetalMap ("Metal Map", 2D) = "white" {} //����������ͼ

        [Header(Emission)]
        [Toggle(_EMISSION)] _UseEmission ("Use Emission", Float) = 0
        _EmissionIntensity ("Emission Intensity", Range(0, 1)) = 1

        [Header(Face)]
        [Toggle(_IS_FACE)] _IsFace ("Is Face", Float) = 0 
        _FaceDirection ("Face Direction", Vector) = (0,0,1,0) //�泯��������
        _FaceShadowOffset ("Face Shadow Offset", Float) = 0 //�沿��Ӱƫ�ƾ���
        _FaceBlushColor ("Face Blush Color", Color) = (1,1,1,1) //
        _FaceBlushStrength ("Face Blush Strength", Float) = 1
        _FaceLightMap ("Face Light Map", 2D) = "white" {} //�沿������ͼ
        _FaceShadow ("Face Shadow", 2D) = "white" {} //�沿��Ӱ��Χ

        [Header(Rim Light)]
        [Toggle(_Use_Rim)] _UseRim ("Use Rim", Float) = 0 
        _RimOffset ("Rim Offset", Range(0, 1)) = 0.6 //��Ե����
        _RimThreshold ("Rim Threshold", Range(0, 1)) = 1 //��Ե�ⷶΧ
        _RimIntensity ("Rim Intensity", Range(0, 1)) = 1 //��Ե��ǿ��
        _RimColor ("Rim Color", Color) = (1, 1, 1, 1) //��Ե����ɫ

        [Header(Outline)]
        [Toggle(_Use_Outline)] _UseOutline ("Use Outline", Float) = 1
        _OutlineWidth ("Outline Width", Range(0, 1)) = 0.2 //��߿��
        _OutlineColor ("outline Color", Color) = (0, 0, 0, 0) //�����ɫ
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
                o.pos = vertexInput.positionCS; //��ȡ�ü��ռ䶥������
                o.positionWS = vertexInput.positionWS; //��ȡ����ռ䶥������
                o.positionNDC = vertexInput.positionNDC; //��ȡ��׼���豸����Ķ�������
                o.normalWS = normalInput.normalWS; //��ȡ����ռ䷨������
                o.tangentWS = normalInput.tangentWS; //��ȡ����ռ���������
                o.bitangentWS = normalInput.bitangentWS; //��ȡ����ռ丱��������
                o.viewDir = GetWorldSpaceNormalizeViewDir(o.positionWS); //��ȡ����ռ���������
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap); //��ȡ����UV��Ϣ
                o.backUV = TRANSFORM_TEX(v.uv, _BaseMap); //��ȡ����ռ䷨������

                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                #if _NORMAL_MAP //�ж��Ƿ�ʹ�÷�����ͼ
                    half3 bump = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, i.uv)); //��ȡ���߿ռ�ķ�����ͼ��Ϣ
                    half3x3 tangentToWorld = half3x3(i.tangentWS, i.bitangentWS, i.normalWS); //��ȡ�����߿ռ䵽����ռ�ľ���
                    i.normalWS = TransformTangentToWorld(bump, tangentToWorld, true); //�õ�����ռ�ķ�����ͼ��Ϣ
                #endif
                Light mainLight = GetMainLight(); //����Դ
                half3 N = SafeNormalize(i.normalWS); //��һ��������ռ䷨��
                half3 V = SafeNormalize(i.viewDir); //��һ��������ռ����߷���
                half3 L = SafeNormalize(mainLight.direction); //��һ��������ռ�����Դ����
                half3 H = SafeNormalize(V + L); //��һ��������ռ�������
                half3 normalVS = TransformWorldToViewNormal(N, true); //��һ���Ĺ۲�ռ䷨��
                
                half2 matcapUV = normalVS.xy * 0.5 + 0.5; //�����߿ռ䷨�߻�ȡһ��matcapUV
                half4 lightMap = SAMPLE_TEXTURE2D(_LightMap, sampler_LightMap, i.uv); //��ȡ������ͼ

                //BaseColor
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv); //����������в���
                half3 toon = SAMPLE_TEXTURE2D(_ToonMap, sampler_ToonMap, matcapUV); //��matcapUV�Կ�ͨ������в���
                half3 albedo = lerp(_BaseColor, _BaseColor.rgb * baseMap.rgb , 1); //�������������ɫ���
                albedo = lerp(albedo, albedo * toon, _ToonFac); ////������ɫ�뿨ͨ������

                #if _IS_FACE
                    //baseColor = lerp(baseColor, baseColor * half3(1,0,0), _FaceBlushStrength * baseMap.a); //����
                #endif

                //Diffuse
                //��ȡRamp��������Ϣ
                int index = 4;
                #if _NOT_HAIR
                    index = lerp(index, 1, step(0.2, lightMap.a));
                    index = lerp(index, 3, step(0.8, lightMap.a));
                #endif

                half halfLambert = pow(dot(L, N) * 0.5 + 0.5, 2); //�õ��������ط������������
                half shadow = 0.0;

                #if _IS_FACE
                    half3 faceDir = half3(_FaceDirection.x, 0.0, _FaceDirection.z); //��ȡ�沿����
                    half3 lightDir = half3(L.x, 0.0, L.z); //��ȡ���շ�������
                    half FdotL = dot(faceDir, lightDir); //��ȡ���շ������沿�����ĵ��
                    half FcrossL = cross(faceDir, lightDir).y; //��ȡ���շ������沿�����ĳ���

                    half2 faceUV = i.uv;
                    faceUV.x = lerp(faceUV.x, 1 - faceUV.x, step(0, FcrossL)); //��ȡ�沿��Ӱ���������沿��ӰUV
                    half faceshadow = SAMPLE_TEXTURE2D(_FaceLightMap, sampler_FaceLightMap, faceUV); //������Ӱ������ͼ
                    shadow = step(-0.5 * FdotL + 0.5, faceshadow); //�������ط����沿��Ӱ����

                     half faceMask = SAMPLE_TEXTURE2D(_FaceShadow, sampler_FaceShadow, i.uv).a; //��ȡ�沿��Ӱ��Χ 
                     shadow =1 - lerp(shadow, 1.0, faceMask); //���沿��Ӱ��Χ��������

                     index = 3;
                #else
                    shadow = saturate(halfLambert * lightMap.g * 2); //�ù�����ͼ��gͨ����ao��ͼ����ȡ������Ӱ��Ϣ
                    shadow = lerp(shadow, 1, step(0.9, lightMap.g)); //����Ӱ��Χ���й���

                #endif

                //��Ӱ��Χ
                half rampMax = _ShadowOffset / 2; 
                half rampMin = _ShadowOffset / 2 - _ShadowSmoothness / 2;
                //��ȡRampUV
                half rampU = smoothstep(rampMin, rampMax, shadow) ;
                half rampV = index / 10.0 + 0.05 + _IsDay * 0.5;
                half2 rampUV = half2(rampU, rampV);

                half3 diffuse = SAMPLE_TEXTURE2D(_ShadowRamp, sampler_ShadowRamp, rampUV);//��RampUV��Ramp����
                diffuse = lerp(diffuse, 1, step(rampMax, shadow)); //��������Ӱ��Χ������Ϊ����Ӱ

                //Specular
                half3 specular = 0;
                #if _USE_SPECULAR
                    half blinnPhone = pow(saturate(dot(N, H)), _SpecularSmoothness);
                    half3 metalMap = SAMPLE_TEXTURE2D(_MetalMap, sampler_MetalMap, matcapUV); //ʹ��matcapUV�Խ��������������

                    half3 metal = blinnPhone * metalMap * lightMap.b * _MetallicIntensty * 2; //��ȡ�����߹ⷶΧ
                    half3 nonmetal = lightMap.r * step(1.1 - blinnPhone, lightMap.b) * _NonmetallicIntensity; //��ȡ�ǽ����߹ⷶΧ
                    specular = lerp(metal, nonmetal, step(0.9, lightMap.r)); //��Ͻ����߹�ͷǽ����߹�
                #endif
                
                //Emission
                half3 emission = 0;
                #if _EMISSION
                    emission = step(0.5, baseMap.a) * _EmissionIntensity * 10; //ͨ������͸�����жϲ����Ƿ�Ϊ�����
                #endif

                //Rim
                half rim = 0;

                #if _Use_Rim
                    half2 screenUV = i.positionNDC.xy / i.positionNDC.w; //ͨ����Ļ���������ȡ��ĻUV 
                    half sceneDepth = SampleSceneDepth(screenUV); //��ȡ�������
                    half depth = LinearEyeDepth(sceneDepth, _ZBufferParams); //��ȡ�۲����
                    half2 offsetUV = half2(normalVS.x * _RimOffset * 10.0 / _ScreenParams.x, 0.0); //��ȡ��Ե���ȣ�ƫ������
                    half offsetDepth = SampleSceneDepth(screenUV + offsetUV);
                    half offset = LinearEyeDepth(offsetDepth, _ZBufferParams);

                    rim = smoothstep(0.0, _RimThreshold, offset - depth) * _RimIntensity; //ͨ��ƫ������۲���ȵĲ��ȡ����Ļ�����Ե��
                    rim = rim * pow(saturate(1 - dot(N, V)), 5.0); //����Ե��
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
                //��ȡ��ƽ�����ߣ������������У�����ƫ�ƵĶ�����Ϣ
                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz + v.tangent * _OutlineWidth * 0.002);//��ȡ��ƽ�����ߣ������������У�����ƫ�ƵĶ�����Ϣ
                
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
                
                return 0; //��������ɫ
            }

            ENDHLSL
        }
    }
}
