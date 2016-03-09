//Version=1.3
Shader"UNOShader/_Library/UNLIT/UNOShaderUNLIT Transparent OutAdv "
{
	Properties
	{
		_Transparency ("Transparency", Range(0,1)) = 1
		_EdgeBias ("Edge Bias", Range(0,5)) = 0
		_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
		_OutlineTex ("Outline Texture", 2D) = "white" {}
		_OutlineColor ("Outline Color", Color) = (0,0,0,0)
		_OutlineX ("Outline X", Range (0, .05)) = .01
		_OutlineY("Outline Y", Range (0, .05)) = .01
		_OutlineEmission ("Outline Emission", Range (0, 10)) = 10
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
				UNITY_FOG_COORDS(5)
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
			//__________________________________ Mask Occlussion _____________________________________
				#if maskTex_ON
				//--- Oclussion from alpha
				resultRGB.rgb = resultRGB.rgb * T_Masks.a;
				#endif

			//__________________________________ Fog  _____________________________________
				UNITY_APPLY_FOG(i.fogCoord, resultRGB);

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
		UsePass "UNOShader/_Library/Helpers/Outlines/ADVANCED"
	} //-------------------------------SubShader-------------------------------
	Fallback "UNOShader/_Library/Helpers/VertexUNLIT Transparent"
	CustomEditor "UNOShader_UNLIT"
}