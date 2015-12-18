Shader "Custom/TestMVPTransform" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include"unitycg.cginc"
			
			float4x4 mvp;
			float4x4 sm;
			struct v2f {
				float4 pos : POSITION;
			};
			
			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = mul(mul(UNITY_MATRIX_MVP,sm),v.vertex);
				return o;
			}
			fixed4 frag():COLOR
			{
				return fixed4(.5,1,1,1);
			}				
			ENDCG
		} 
	}
	FallBack "Diffuse"
}
