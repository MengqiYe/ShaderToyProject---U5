//Version=1.3
Shader"UNOShader/_Library/UNLIT/UNOShaderUNLIT Color OutBasic "
{
	Properties
	{
		_Color ("Color (A)Opacity", Color) = (1,1,1,1)
		_OutlineColor ("Outline Color", Color) = (0,0,0,0)
		_Outline ("Outline Width", Range (0, .05)) = .01
		_OutlineEmission ("Outline Emission", Range (0, 10)) = 10
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
			#pragma multi_compile maskTex_ON maskTex_OFF
			#pragma multi_compile mathPixel_ON mathPixel_OFF
			#pragma multi_compile_fog
			#if maskTex_ON
			sampler2D _MasksTex;
			float4 _MasksTex_ST;
			#endif
			fixed4 _Color;
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
				UNITY_FOG_COORDS(5)
			};
			v2f vert (customData v)
			{
				v2f o;
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);//UNITY_MATRIX_MVP is a matrix that will convert a model's vertex position to the projection space
				o.uv = fixed4(0,0,0,0);
				o.uv.xy = v.texcoord;
			//_________________________________________ FOG  __________________________________________
				UNITY_TRANSFER_FOG(o,o.pos);
				return o;
			}

			fixed4 frag (v2f i) : COLOR  // i = in gets info from the out of the v2f vert
			{
				fixed4 resultRGB = fixed4(0,0,0,0);
			//__________________________________ Vectors _____________________________________
				#if maskTex_ON
			//__________________________________ Masks _____________________________________
				fixed4 T_Masks = tex2D(_MasksTex, i.uv.xy);
				#endif
			//__________________________________ Color Base _____________________________________
				resultRGB = _Color;
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
		UsePass "UNOShader/_Library/Helpers/Outlines/BASIC"
	} //-------------------------------SubShader-------------------------------
	Fallback "UNOShader/_Library/Helpers/VertexUNLIT"
	CustomEditor "UNOShader_UNLIT"
}