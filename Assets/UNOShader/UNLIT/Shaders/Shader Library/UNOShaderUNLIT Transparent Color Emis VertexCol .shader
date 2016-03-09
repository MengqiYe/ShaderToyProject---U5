//Version=1.3
Shader"UNOShader/_Library/UNLIT/UNOShaderUNLIT Transparent Color Emis VertexCol "
{
	Properties
	{
		_Color ("Color (A)Opacity", Color) = (1,1,1,1)
		_EmissionColor ("Emission Tint", Color) = (1,.7,.3,0)
		_EmissionMap ("Emission Texture (A)Mask", 2D) = "white" {}
		_EmissionIntensity ("Emission Intensity", Range(1,10) ) = 1
		_EmissionBakeIntensity ("LightmapBake Intensity", Range(1,20) ) = 2 //unity needs its for lightmap baking
		_Transparency ("Transparency", Range(0,1)) = 1
		_EdgeBias ("Edge Bias", Range(0,5)) = 0
		_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
		_MasksTex ("Masks", 2D) = "white" {}
	}
	SubShader
	{
		Tags
		{
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
		}
			Offset -1.0,0
			Blend SrcAlpha OneMinusSrcAlpha // --- not needed when doing cutout
		Pass
			{
			Name "ForwardBase"
			Tags
			{
				"RenderType" = "Transparent"
				"Queue" = "Transparent"
				"LightMode" = "ForwardBase"
			}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#pragma multi_compile maskTex_ON maskTex_OFF
			#pragma multi_compile mathPixel_ON mathPixel_OFF
			#pragma multi_compile NONE_EDGETRANSPARENCY NORMAL_EDGETRANSPARENCY INVERTED_EDGETRANSPARENCY
			#pragma multi_compile_fog
			fixed _Transparency;
			fixed _EdgeBias;
			#if maskTex_ON
			sampler2D _MasksTex;
			float4 _MasksTex_ST;
			#endif
			fixed4 _Color;

			fixed4 _EmissionColor;
			sampler2D _EmissionMap;
			float4 _EmissionMap_ST;
			fixed _EmissionIntensity;
			float4x4 _MatrixEmission;
			struct customData
			{
				float4 vertex : POSITION;
				half3 normal : NORMAL;
				float4 tangent : TANGENT;
				fixed2 texcoord : TEXCOORD0;
				fixed2 texcoord1 : TEXCOORD1;
				fixed4 color : COLOR;
			};
			struct v2f // = vertex to fragment ( pass vertex data to pixel pass )
			{
				float4 pos : SV_POSITION;
				fixed4 vc : COLOR;
				fixed4 uv : TEXCOORD0;
				fixed4 uv2 : TEXCOORD1;
				float4 posWorld : TEXCOORD2;//position of vertex in world;
				half4 normalDir : TEXCOORD3;//vertex Normal Direction in world space
				UNITY_FOG_COORDS(5)
			};
			v2f vert (customData v)
			{
				v2f o;
				o.posWorld = mul(_Object2World, v.vertex);
				o.normalDir = fixed4 (0,0,0,0);
				o.normalDir.xyz = UnityObjectToWorldNormal(v.normal);
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);//UNITY_MATRIX_MVP is a matrix that will convert a model's vertex position to the projection space
				o.vc = v.color;// Vertex Colors
				o.uv = fixed4(0,0,0,0);
				o.uv.xy = v.texcoord;
				o.uv2 = fixed4(0,0,0,0);
				o.uv2.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw; //Unity matrix lightmap uvs
				o.uv2.zw = TRANSFORM_TEX (v.texcoord, _EmissionMap); // this allows you to offset uvs and such
				o.uv2.zw = mul(_MatrixEmission, fixed4(o.uv2.zw,0,1)); // this allows you to rotate uvs and such with script help
				#if mathPixel_OFF
				half3 viewDir = normalize(ObjSpaceViewDir(v.vertex));
				#endif
			//_________________________________________ FOG  __________________________________________
				UNITY_TRANSFER_FOG(o,o.pos);
				return o;
			}

			fixed4 frag (v2f i) : COLOR  // i = in gets info from the out of the v2f vert
			{
				fixed4 resultRGB = fixed4(0,0,0,0);
			//__________________________________ Vectors _____________________________________
				float3 normalDirection = normalize(i.normalDir);
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);//  float3 _WorldSpaceCameraPos.xyz built in gets camera Position
				float fresnel = dot(viewDir, normalDirection);
				#if maskTex_ON
			//__________________________________ Masks _____________________________________
				fixed4 T_Masks = tex2D(_MasksTex, i.uv.xy);
				#endif
			//__________________________________ Color Base _____________________________________
				resultRGB = _Color;
			//__________________________________ Vertex Color _____________________________________
				resultRGB.rgb = resultRGB.rgb * i.vc.rgb;

			//__________________________________ Emission _____________________________________
				fixed4 T_Emission = tex2D (_EmissionMap, i.uv2.zw);
				resultRGB = lerp (resultRGB,fixed4((T_Emission.rgb * _EmissionColor) * _EmissionIntensity,T_Emission.a),T_Emission.a);

			//__________________________________ Mask Occlussion _____________________________________
				#if maskTex_ON
				//--- Oclussion from alpha
				resultRGB.rgb = resultRGB.rgb * T_Masks.a;
				#endif

			//__________________________________ Fog  _____________________________________
				UNITY_APPLY_FOG(i.fogCoord, resultRGB);

			//__________________________________ Vertex Alpha _____________________________________
				resultRGB.a *= i.vc.a;

			//__________________________________ Transparency master _____________________________________
				fixed edgeTransparency = _Transparency;
				#if NORMAL_EDGETRANSPARENCY
				edgeTransparency =  pow(clamp(fresnel,0,1),_EdgeBias)* _Transparency;
				#endif
				#if INVERTED_EDGETRANSPARENCY
				edgeTransparency =  pow(clamp((1-fresnel),0,1),_EdgeBias)* _Transparency;
				#endif
				resultRGB.a *=  edgeTransparency;
			//__________________________________ result Final  _____________________________________
				return resultRGB;
			}
			ENDCG
		}//-------------------------------Pass-------------------------------
		Pass
		{
			Name "Meta"
			Tags 
			{
				"LightMode"="Meta"
			}
			Cull Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define UNITY_PASS_META 1
			#define _GLOSSYENV 1
			#include "UnityCG.cginc"
			#include "UnityPBSLighting.cginc"
			#include "UnityStandardBRDF.cginc"
			#include "UnityMetaPass.cginc"
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma multi_compile_shadowcaster
			#pragma multi_compile_fog
			#pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
			#pragma target 3.0
			uniform float4 _EmissionColor;
			uniform float _EmissionBakeIntensity;
			uniform sampler2D _EmissionMap; uniform float4 _EmissionMap_ST;
			struct VertexInput 
			{
				float4 vertex : POSITION;
				float2 texcoord0 : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
				float2 texcoord2 : TEXCOORD2;
			};
			struct VertexOutput 
			{
				float4 pos : SV_POSITION;
				float2 uv0 : TEXCOORD0;
			};
			VertexOutput vert (VertexInput v) 
			{
				VertexOutput o = (VertexOutput)0;
				o.uv0 = v.texcoord0;
				o.pos = UnityMetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord2.xy, unity_LightmapST, unity_DynamicLightmapST );
				return o;
			}
			float4 frag(VertexOutput i) : SV_Target 
			{
				/////// Vectors:
				UnityMetaInput o;
				UNITY_INITIALIZE_OUTPUT( UnityMetaInput, o );
				float4 _EmissionMap_var = tex2D(_EmissionMap,TRANSFORM_TEX(i.uv0, _EmissionMap));

				o.Emission = ((_EmissionColor.rgb*_EmissionMap_var.rgb)*_EmissionBakeIntensity);

				float3 diffColor = float3(0,0,0);
				o.Albedo = diffColor;

				return UnityMetaFragment( o );
			}
			ENDCG
		}
	} //-------------------------------SubShader-------------------------------
	Fallback "UNOShader/_Library/Helpers/VertexUNLIT Transparent"
	CustomEditor "UNOShader_UNLIT"
}