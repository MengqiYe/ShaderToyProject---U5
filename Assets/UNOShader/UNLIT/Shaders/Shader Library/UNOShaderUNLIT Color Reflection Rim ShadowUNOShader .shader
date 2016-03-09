//Version=1.3
Shader"UNOShader/_Library/UNLIT/UNOShaderUNLIT Color Reflection Rim ShadowUNOShader "
{
	Properties
	{
		_Color ("Color (A)Opacity", Color) = (1,1,1,1)
		_Cube ("Cubemap(A)Luminance", Cube) = "white" {}
		_CubeOpacity ("Ref Opacity", Range (0, 1)) = 1
		_CubeBias ("Ref Bias", Range (0, 5)) = 1
		_RimColor ("Rim Color (A)Opacity", Color) = (1,1,1,1)
		_RimBias ("Rim Bias", Range (0, 5)) = 1
		_MasksTex ("Masks", 2D) = "white" {}
	}
	SubShader
	{
		Tags
		{
			"RenderType" = "Opaque"
			"Queue" = "Geometry"
		}
		Pass
			{
			Name "ForwardBase"
			Tags
			{
				"RenderType" = "Opaque"
				"Queue" = "Geometry"
				"LightMode" = "ForwardBase"
			}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#pragma multi_compile_fwdbase
			#pragma multi_compile lmUV1_ON lmUV1_OFF
			#pragma multi_compile maskTex_ON maskTex_OFF
			#pragma multi_compile mathPixel_ON mathPixel_OFF
			#pragma multi_compile_fog
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "AutoLight.cginc"
			#include "Lighting.cginc"

			#if maskTex_ON
			sampler2D _MasksTex;
			float4 _MasksTex_ST;
			#endif
			fixed4 _Color;

			samplerCUBE _Cube;
			fixed _CubeOpacity;
			fixed _CubeBias;

			half3 DecodeRGBM(float4 rgbm)
			{
			fixed MaxRange=8;
			return rgbm.rgb * (rgbm.a * MaxRange);
			}


			fixed4 _RimColor;
			fixed _RimBias;

			fixed4 _UNOShaderShadowColor;
			struct customData
			{
				float4 vertex : POSITION;
				half3 normal : NORMAL;
				float4 tangent : TANGENT;
				fixed2 texcoord : TEXCOORD0;
			};
			struct v2f // = vertex to fragment ( pass vertex data to pixel pass )
			{
				float4 pos : SV_POSITION;
				fixed4 uv : TEXCOORD0;
				float4 posWorld : TEXCOORD2;//position of vertex in world;
				half4 normalDir : TEXCOORD3;//vertex Normal Direction in world space
				half4 viewRefDir : TEXCOORD4;
				UNITY_FOG_COORDS(5)
				LIGHTING_COORDS(6, 7)
			};
			v2f vert (customData v)
			{
				v2f o;
				o.posWorld = mul(_Object2World, v.vertex);
				o.normalDir = fixed4 (0,0,0,0);
				o.normalDir.xyz = UnityObjectToWorldNormal(v.normal);
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);//UNITY_MATRIX_MVP is a matrix that will convert a model's vertex position to the projection space
				o.uv = fixed4(0,0,0,0);
				o.uv.xy = v.texcoord;
				o.viewRefDir = fixed4(0,0,0,0);
				#if mathPixel_OFF
				half3 viewDir = normalize(ObjSpaceViewDir(v.vertex));
				half3 viewNormal = normalize(WorldSpaceViewDir(v.vertex));
				o.viewRefDir.xyz = reflect(-viewNormal, o.normalDir);
				o.viewRefDir.w = ( 1-(clamp((dot(viewDir, v.normal) * _CubeBias),0,1)) ) * _CubeOpacity;//alternavit math
				o.normalDir.w = ( 1-(clamp((dot(viewDir, v.normal) * _RimBias),0,1)) ) * _RimColor.a;
				#endif
				TRANSFER_VERTEX_TO_FRAGMENT(o) // This sets up the vertex attributes required for lighting and passes them through to the fragment shader.
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
				float atten = LIGHT_ATTENUATION(i); // This gets the shadow and attenuation values combined.
			//__________________________________ Reflection _____________________________________
				#if mathPixel_ON
				float3 viewRefDir = reflect(-viewDir, normalDirection );
				fixed RefOpacity = (1-(clamp(fresnel * _CubeBias,0,1))) * _CubeOpacity;
				#endif
				#if mathPixel_OFF
				float3 viewRefDir = i.viewRefDir.xyz;
				fixed RefOpacity = i.viewRefDir.w;
				#endif
				fixed4 Cubemap = texCUBE(_Cube, viewRefDir);
				fixed4 CubemapR = float4(DecodeRGBM(Cubemap),Cubemap.a*8);
				#if maskTex_ON
				RefOpacity *= T_Masks.r;
				#endif
				resultRGB = lerp (resultRGB ,resultRGB + CubemapR, RefOpacity);

			//__________________________________ Rim _____________________________________
				#if mathPixel_ON			
				fixed RimOpacity = (1-(clamp(fresnel * _RimBias ,0,1))) * _RimColor.a;
				#endif
				#if mathPixel_OFF
				fixed RimOpacity = i.normalDir.w;
				#endif
				#if maskTex_ON
				RimOpacity *= T_Masks.b;
				#endif
				resultRGB = lerp (resultRGB, _RimColor, RimOpacity);

			//__________________________________ Custom Shadow Color _____________________________________
				#ifdef LIGHTMAP_ON
				resultRGB.rgb = lerp(resultRGB * _UNOShaderShadowColor,resultRGB,atten);
				#endif
				#ifdef LIGHTMAP_OFF
				resultRGB.rgb = lerp(resultRGB * _UNOShaderShadowColor,resultRGB,atten);
				#endif
			//__________________________________ Mask Occlussion _____________________________________
				#if maskTex_ON
				//--- Oclussion from alpha
				resultRGB.rgb = resultRGB.rgb * T_Masks.a;
				#endif

			//__________________________________ Fog  _____________________________________
				UNITY_APPLY_FOG(i.fogCoord, resultRGB);

			//__________________________________ result Final  _____________________________________
				return resultRGB;
			}
			ENDCG
		}//-------------------------------Pass-------------------------------
		UsePass "UNOShader/_Library/Helpers/Shadows/SHADOWCAST"
		UsePass "UNOShader/_Library/Helpers/Shadows/SHADOWCOLLECTOR"
	} //-------------------------------SubShader-------------------------------
	Fallback "UNOShader/_Library/Helpers/VertexUNLIT"
	CustomEditor "UNOShader_UNLIT"
}