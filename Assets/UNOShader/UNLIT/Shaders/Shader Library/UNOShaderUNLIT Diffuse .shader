//Version=1.3
Shader"UNOShader/_Library/UNLIT/UNOShaderUNLIT Diffuse "
{
	Properties
	{
		_MainTex ("Diffuse Texture", 2D) = "white" {}
		_MainTexOpacity ("Diffuse Opacity", Range (0, 1)) = 1
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

			float _MainTexOpacity;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4x4 _MatrixDiffuse;
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
				o.uv.xy = TRANSFORM_TEX (v.texcoord, _MainTex); // this allows you to offset uvs and such	
				o.uv.xy = mul(_MatrixDiffuse, fixed4(o.uv.xy,0,1)); // this allows you to rotate uvs and such with script help
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
			//__________________________________ Diffuse _____________________________________
				fixed4 T_Diffuse = tex2D(_MainTex, i.uv.xy);
				resultRGB = lerp(resultRGB,fixed4(T_Diffuse.rgb,1),(T_Diffuse.a * _MainTexOpacity));

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
	} //-------------------------------SubShader-------------------------------
	Fallback "UNOShader/_Library/Helpers/VertexUNLIT"
	CustomEditor "UNOShader_UNLIT"
}